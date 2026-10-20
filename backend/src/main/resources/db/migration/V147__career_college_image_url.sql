-- Card thumbnails for careers and colleges.
--
-- Schema only: no rows are written here. Which image a career or college shows
-- is content, so it is set through the admin (MigrationPolicyTest fails the
-- build if a migration after V146 writes to a content table). Null means "no
-- image", and the listing cards fall back to the icon they show today.
--
-- Either a path served by the site itself ("/thumbnails/careers/law.webp", a
-- file under public/ in the frontend) or an https URL. Not http: browsers
-- block plain-http images on an https page, so such a value would render as a
-- broken image. Not javascript:, data: or anything else an <img src> could be
-- tricked with. The same rule is enforced in CareerUpsertRequest and
-- CollegeUpsertRequest; this CHECK covers writes that bypass the API.

ALTER TABLE careers  ADD COLUMN image_url varchar(500);
ALTER TABLE colleges ADD COLUMN image_url varchar(500);

ALTER TABLE careers ADD CONSTRAINT careers_image_url_format
    CHECK (image_url IS NULL OR image_url ~ '^(/(?!/)[A-Za-z0-9._~/-]+|https://[^[:space:]"''<>]+)$');
ALTER TABLE colleges ADD CONSTRAINT colleges_image_url_format
    CHECK (image_url IS NULL OR image_url ~ '^(/(?!/)[A-Za-z0-9._~/-]+|https://[^[:space:]"''<>]+)$');
