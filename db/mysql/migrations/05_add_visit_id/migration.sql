-- AlterTable
ALTER TABLE `website_event` ADD COLUMN `visit_id` VARCHAR(36) NULL;

UPDATE `website_event` we
JOIN (SELECT DISTINCT
        s.session_id,
        s.visit_time,
        SELECT LOWER(CONCAT(
    HEX(RANDOM_BYTES(4)), '-',
    HEX(RANDOM_BYTES(2)), '-4',
    SUBSTR(HEX(RANDOM_BYTES(2)), 2, 3), '-',
    CONCAT(HEX(FLOOR(ASCII(RANDOM_BYTES(1)) / 64)+8),SUBSTR(HEX(RANDOM_BYTES(2)), 2, 3)), '-',
    HEX(RANDOM_BYTES(6))
))
    FROM (SELECT DISTINCT session_id,
            DATE_FORMAT(created_at, '%Y-%m-%d %H:00:00') visit_time
        FROM `website_event`) s) a
    ON we.session_id = a.session_id and DATE_FORMAT(we.created_at, '%Y-%m-%d %H:00:00') = a.visit_time
SET we.visit_id = a.uuid
WHERE we.visit_id IS NULL;

ALTER TABLE `website_event` MODIFY `visit_id` VARCHAR(36) NOT NULL;

-- CreateIndex
CREATE INDEX `website_event_visit_id_idx` ON `website_event`(`visit_id`);

-- CreateIndex
CREATE INDEX `website_event_website_id_visit_id_created_at_idx` ON `website_event`(`website_id`, `visit_id`, `created_at`);
