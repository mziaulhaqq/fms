import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { SiteSupervisorsService } from '../../site-supervisors/site-supervisors.service';

/**
 * Guard to check if a user has access to a specific site
 * Looks for siteId in request body, query params, or path params
 */
@Injectable()
export class SiteAccessGuard implements CanActivate {
  constructor(
    private reflector: Reflector,
    private siteSupervisorsService: SiteSupervisorsService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user || !user.sub) {
      throw new ForbiddenException('User not authenticated');
    }

    // Extract siteId from request (body, query, or params)
    const siteId = this.extractSiteId(request);

    // If no siteId found, allow the request (some endpoints don't require site context)
    if (!siteId) {
      return true;
    }

    // Check if user has access to this site
    const hasAccess = await this.siteSupervisorsService.hasAccessToSite(
      user.sub,
      siteId,
    );

    if (!hasAccess) {
      throw new ForbiddenException(
        `You do not have access to site with ID ${siteId}`,
      );
    }

    return true;
  }

  private extractSiteId(request: any): number | null {
    // Check body
    if (request.body?.siteId) {
      return parseInt(request.body.siteId, 10);
    }

    // Check query params
    if (request.query?.siteId) {
      return parseInt(request.query.siteId, 10);
    }

    // Check path params
    if (request.params?.siteId) {
      return parseInt(request.params.siteId, 10);
    }

    return null;
  }
}
