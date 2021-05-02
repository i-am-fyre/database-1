-- ----------------------------------------------------------------
-- This is an attempt to create a full transactional MaNGOS update
-- Now compatible with newer MySql Databases (v1.5)
-- ----------------------------------------------------------------
DROP PROCEDURE IF EXISTS `update_mangos`; 

DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_mangos`()
BEGIN
    DECLARE bRollback BOOL  DEFAULT FALSE ;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET `bRollback` = TRUE;

    -- Current Values (TODO - must be a better way to do this)
    SET @cCurVersion := (SELECT `version` FROM `db_version` ORDER BY `version` DESC, `STRUCTURE` DESC, `CONTENT` DESC LIMIT 0,1);
    SET @cCurStructure := (SELECT `structure` FROM `db_version` ORDER BY `version` DESC, `STRUCTURE` DESC, `CONTENT` DESC LIMIT 0,1);
    SET @cCurContent := (SELECT `content` FROM `db_version` ORDER BY `version` DESC, `STRUCTURE` DESC, `CONTENT` DESC LIMIT 0,1);

    -- Expected Values
    SET @cOldVersion = '21'; 
    SET @cOldStructure = '14'; 
    SET @cOldContent = '008';

    -- New Values
    SET @cNewVersion = '21';
    SET @cNewStructure = '14';
    SET @cNewContent = '009';
                            -- DESCRIPTION IS 30 Characters MAX    
    SET @cNewDescription = 'Quest: Proving Pit';

                        -- COMMENT is 150 Characters MAX
    SET @cNewComment = 'Scripted the Proving Pit quests on Echo Isles';

    -- Evaluate all settings
    SET @cCurResult := (SELECT `description` FROM `db_version` ORDER BY `version` DESC, `STRUCTURE` DESC, `CONTENT` DESC LIMIT 0,1);
    SET @cOldResult := (SELECT `description` FROM `db_version` WHERE `version`=@cOldVersion AND `structure`=@cOldStructure AND `content`=@cOldContent);
    SET @cNewResult := (SELECT `description` FROM `db_version` WHERE `version`=@cNewVersion AND `structure`=@cNewStructure AND `content`=@cNewContent);

    IF (@cCurResult = @cOldResult) THEN    -- Does the current version match the expected version
        -- APPLY UPDATE
        START TRANSACTION;
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
        -- -- PLACE UPDATE SQL BELOW -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -


-- Add new conditions - for every class's version of Proving Pit (-2 indicates OR statements)
SET @maxConditionEntry := (SELECT max(`condition_entry`) FROM `conditions`);
INSERT INTO `conditions` (`condition_entry`, `type`, `value1`, `value2`, `comments`) VALUES
  ((@maxConditionEntry + 1), 9, 26276, 0, "Proving Pits - Warlock"),
  ((@maxConditionEntry + 2), 9, 24642, 0, "Proving Pits - Warrior"), 
  ((@maxConditionEntry + 3), 9, 24754, 0, "Proving Pits - Mage"),
  ((@maxConditionEntry + 4), 9, 24762, 0, "Proving Pits - Shaman"),
  ((@maxConditionEntry + 5), 9, 24768, 0, "Proving Pits - Druid"),
  ((@maxConditionEntry + 6), 9, 24774, 0, "Proving Pits - Rogue"),
  ((@maxConditionEntry + 7), 9, 24780, 0, "Proving Pits - Hunter"),
  ((@maxConditionEntry + 8), 9, 24786, 0, "Proving Pits - Priest"),
  ((@maxConditionEntry + 9), -2, (@maxConditionEntry + 1), (@maxConditionEntry + 2), "Proving Pits - Warlock OR Warrior"),
  ((@maxConditionEntry + 10), -2, (@maxConditionEntry + 3), (@maxConditionEntry + 9), "Proving Pits - Warlock OR Warrior OR Mage"),
  ((@maxConditionEntry + 11), -2, (@maxConditionEntry + 4), (@maxConditionEntry + 10), "Proving Pits - Warlock OR Warrior OR Mage OR Shaman"),
  ((@maxConditionEntry + 12), -2, (@maxConditionEntry + 5), (@maxConditionEntry + 11), "Proving Pits - Warlock OR Warrior OR Mage OR Shaman OR Druid"),
  ((@maxConditionEntry + 13), -2, (@maxConditionEntry + 6), (@maxConditionEntry + 12), "Proving Pits - Warlock OR Warrior OR Mage OR Shaman OR Druid OR Rogue"),
  ((@maxConditionEntry + 14), -2, (@maxConditionEntry + 7), (@maxConditionEntry + 13), "Proving Pits - Warlock OR Warrior OR Mage OR Shaman OR Druid OR Rogue OR Hunter"),
  ((@maxConditionEntry + 15), -2, (@maxConditionEntry + 8), (@maxConditionEntry + 14), "Proving Pits - Warlock OR Warrior OR Mage OR Shaman OR Druid OR Rogue OR Hunter OR Priest");
  

-- Create db_scripts entry for handling Jailor movement, opening cage, Naga movement, and making Naga active.
SET @maxDBScripts := (SELECT max(`script_guid`) FROM `db_scripts`);
INSERT INTO `db_scripts` (`script_guid`, `script_type`, `id`, `delay`, `command`, `datalong`, `datalong2`, `buddy_entry`, `search_radius`, `data_flags`, `dataint`, `dataint2`, `dataint3`, `dataint4`, `x`, `y`, `z`, `o`, `comments`) VALUES ((@maxDBScripts + 1), 2, 109740, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '-1153.612915', '-5519.226562', '11.995037', '0.005905', 'Move Darkspear Jailor to Captive Spitescale Scout (East Pit)');

-- Updates the gossip_menu_option seen when clicking Darkspear Jailor - should be visible when quest is in quest log.
DELETE FROM `gossip_menu_option` WHERE `menu_id`=10974;
INSERT INTO `gossip_menu_option` (`menu_id`, `id`, `option_icon`, `option_text`, `option_id`, `npc_option_npcflag`, `action_menu_id`, `action_poi_id`, `action_script_id`, `box_coded`, `box_money`, `box_text`, `condition_id`) VALUES (10974, 0, 0, "I'm ready to face my challenge.", 1, 1, -1, 0, 109740, 0, 0, "", (@maxConditionEntry + 15));

-- To-do:
--   Confirm that naga is unattackable while inside the cage.
--   Naga needs to enter into the Proving Pit and become attackable.
--   Duplicate the db_scripts for the other Jailor.
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
        -- -- PLACE UPDATE SQL ABOVE -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -

        -- If we get here ok, commit the changes
        IF bRollback = TRUE THEN
            ROLLBACK;
            SHOW ERRORS;
            SELECT '* UPDATE FAILED *' AS `===== Status =====`,@cCurResult AS `===== DB is on Version: =====`;
        ELSE
            COMMIT;
            -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
            -- UPDATE THE DB VERSION
            -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
            INSERT INTO `db_version` VALUES (@cNewVersion, @cNewStructure, @cNewContent, @cNewDescription, @cNewComment);
            SET @cNewResult := (SELECT `description` FROM `db_version` WHERE `version`=@cNewVersion AND `structure`=@cNewStructure AND `content`=@cNewContent);

            SELECT '* UPDATE COMPLETE *' AS `===== Status =====`,@cNewResult AS `===== DB is now on Version =====`;
        END IF;
    ELSE    -- Current version is not the expected version
        IF (@cCurResult = @cNewResult) THEN    -- Does the current version match the new version
            SELECT '* UPDATE SKIPPED *' AS `===== Status =====`,@cCurResult AS `===== DB is already on Version =====`;
        ELSE    -- Current version is not one related to this update
            IF(@cCurResult IS NULL) THEN    -- Something has gone wrong
                SELECT '* UPDATE FAILED *' AS `===== Status =====`,'Unable to locate DB Version Information' AS `============= Error Message =============`;
            ELSE
                IF(@cOldResult IS NULL) THEN    -- Something has gone wrong
                    SET @cCurVersion := (SELECT `version` FROM `db_version` ORDER BY `version` DESC, `STRUCTURE` DESC, `CONTENT` DESC LIMIT 0,1);
                    SET @cCurStructure := (SELECT `STRUCTURE` FROM `db_version` ORDER BY `version` DESC, `STRUCTURE` DESC, `CONTENT` DESC LIMIT 0,1);
                    SET @cCurContent := (SELECT `Content` FROM `db_version` ORDER BY `version` DESC, `STRUCTURE` DESC, `CONTENT` DESC LIMIT 0,1);
                    SET @cCurOutput = CONCAT(@cCurVersion, '_', @cCurStructure, '_', @cCurContent, ' - ',@cCurResult);
                    SET @cOldResult = CONCAT('Rel',@cOldVersion, '_', @cOldStructure, '_', @cOldContent, ' - ','IS NOT APPLIED');
                    SELECT '* UPDATE SKIPPED *' AS `===== Status =====`,@cOldResult AS `=== Expected ===`,@cCurOutput AS `===== Found Version =====`;
                ELSE
                    SET @cCurVersion := (SELECT `version` FROM `db_version` ORDER BY `version` DESC, `STRUCTURE` DESC, `CONTENT` DESC LIMIT 0,1);
                    SET @cCurStructure := (SELECT `STRUCTURE` FROM `db_version` ORDER BY `version` DESC, `STRUCTURE` DESC, `CONTENT` DESC LIMIT 0,1);
                    SET @cCurContent := (SELECT `Content` FROM `db_version` ORDER BY `version` DESC, `STRUCTURE` DESC, `CONTENT` DESC LIMIT 0,1);
                    SET @cCurOutput = CONCAT(@cCurVersion, '_', @cCurStructure, '_', @cCurContent, ' - ',@cCurResult);
                    SELECT '* UPDATE SKIPPED *' AS `===== Status =====`,@cOldResult AS `=== Expected ===`,@cCurOutput AS `===== Found Version =====`;
                END IF;
            END IF;
        END IF;
    END IF;
END $$

DELIMITER ;

-- Execute the procedure
CALL update_mangos();

-- Drop the procedure
DROP PROCEDURE IF EXISTS `update_mangos`;
