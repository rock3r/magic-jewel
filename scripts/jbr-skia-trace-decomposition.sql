WITH command_frames AS (
  SELECT
    id,
    track_id,
    ts,
    dur,
    ROW_NUMBER() OVER (ORDER BY ts) AS frame_number,
    COUNT(*) OVER () AS frame_count
  FROM slice
  WHERE name = 'commandFrame' AND dur > 0
),
steady_frames AS (
  SELECT *
  FROM command_frames
  WHERE frame_number > 300 AND frame_number <= frame_count - 300
),
per_frame AS (
  SELECT
    frame.id,
    frame.dur AS command_frame_ns,
    MAX(CASE WHEN child.name = 'sceneRender' THEN child.dur ELSE 0 END) AS scene_render_ns,
    MAX(CASE WHEN child.name = 'pictureRecordDiscard' THEN child.dur ELSE 0 END) AS picture_discard_ns,
    MAX(CASE WHEN child.name = 'renderCommandFrame' THEN child.dur ELSE 0 END) AS render_command_ns,
    SUM(CASE WHEN child.name = 'layerRecord' THEN 1 ELSE 0 END) AS recursive_layer_record_count,
    SUM(CASE
      WHEN child.name = 'layerRecord' AND COALESCE(parent.name, '') != 'layerRecord' THEN 1
      ELSE 0
    END) AS top_level_layer_record_count,
    SUM(CASE
      WHEN child.name = 'layerRecord' AND COALESCE(parent.name, '') != 'layerRecord' THEN child.dur
      ELSE 0
    END) AS top_level_layer_record_ns,
    SUM(CASE WHEN child.name = 'compaction' THEN 1 ELSE 0 END) AS compaction_count,
    SUM(CASE WHEN child.name = 'compaction' THEN child.dur ELSE 0 END) AS compaction_ns
  FROM steady_frames AS frame
  LEFT JOIN slice AS child
    ON child.track_id = frame.track_id
    AND child.id != frame.id
    AND child.ts >= frame.ts
    AND child.ts + child.dur <= frame.ts + frame.dur
    AND child.name IN (
      'sceneRender',
      'pictureRecordDiscard',
      'renderCommandFrame',
      'layerRecord',
      'compaction'
    )
  LEFT JOIN slice AS parent ON parent.id = child.parent_id
  GROUP BY frame.id, frame.dur
)
SELECT
  COUNT(*) AS frames,
  ROUND(AVG(command_frame_ns) / 1000000.0, 4) AS command_frame_ms,
  ROUND(AVG(scene_render_ns) / 1000000.0, 4) AS scene_render_record_ms,
  ROUND(AVG(recursive_layer_record_count), 3) AS recursive_layer_records,
  ROUND(AVG(top_level_layer_record_count), 3) AS top_level_layer_records,
  ROUND(AVG(top_level_layer_record_ns) / 1000000.0, 4) AS top_level_layer_record_ms,
  ROUND(AVG(compaction_count), 3) AS compactions,
  ROUND(AVG(compaction_ns) / 1000000.0, 4) AS compaction_subset_ms,
  ROUND(AVG(picture_discard_ns) / 1000000.0, 4) AS picture_discard_ms,
  ROUND(AVG(
    command_frame_ns - scene_render_ns - picture_discard_ns - render_command_ns
  ) / 1000000.0, 4) AS serialization_and_bookkeeping_residual_ms,
  ROUND(AVG(render_command_ns) / 1000000.0, 4) AS render_command_java_to_native_ms
FROM per_frame;
