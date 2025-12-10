import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ROLES_KEY } from '../decorators/roles.decorator';
import { UserAssignedRoles } from '../../../entities/UserAssignedRoles.entity';
import { UserRoles } from '../../../entities/UserRoles.entity';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(
    private reflector: Reflector,
    @InjectRepository(UserAssignedRoles)
    private userAssignedRolesRepository: Repository<UserAssignedRoles>,
    @InjectRepository(UserRoles)
    private userRolesRepository: Repository<UserRoles>,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const requiredRoles = this.reflector.getAllAndOverride<string[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);

    // If no roles are required, allow access
    if (!requiredRoles) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user) {
      throw new ForbiddenException('User not authenticated');
    }

    // Get user's assigned roles
    const userAssignedRoles = await this.userAssignedRolesRepository.find({
      where: { 
        userId: user.id,
        status: 'active' 
      },
      relations: ['role'],
    });

    if (!userAssignedRoles || userAssignedRoles.length === 0) {
      throw new ForbiddenException('User has no roles assigned');
    }

    // Check if user has any of the required roles
    const userRoleNames = userAssignedRoles
      .map(uar => uar.role?.name)
      .filter(name => name !== null && name !== undefined);

    const hasRole = requiredRoles.some(role => userRoleNames.includes(role));

    if (!hasRole) {
      throw new ForbiddenException(
        `Access denied. Required roles: ${requiredRoles.join(', ')}`
      );
    }

    return true;
  }
}
