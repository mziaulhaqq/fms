import { SetMetadata } from '@nestjs/common';

export const REQUIRE_SITE_ACCESS_KEY = 'requireSiteAccess';
export const RequireSiteAccess = () => SetMetadata(REQUIRE_SITE_ACCESS_KEY, true);
