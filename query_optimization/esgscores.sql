-- create indexes first
-- they should all be unique
CREATE UNIQUE INDEX esg_id ON data_challenges.esg_scores(id);
CREATE UNIQUE INDEX idmap_id ON data_challenges.id_map(id);
CREATE UNIQUE INDEX idmap_iid ON data_challenges.id_map(instr_id);
CREATE UNIQUE INDEX sp_iid ON data_challenges.sp500(instr_id);

-- joining esg_scores with sp_500 to make sp500_esg_scores table
SELECT data_challenges.id_map.id, total_score, 
e_score, s_score, g_score, 
data_challenges.sp500.instr_id, name
INTO data_challenges.sp500_esg_scores
FROM data_challenges.id_map
LEFT JOIN data_challenges.esg_scores ON data_challenges.id_map.id=data_challenges.esg_scores.id
RIGHT JOIN data_challenges.sp500 ON data_challenges.id_map.instr_id=data_challenges.sp500.instr_id;

-- added score_rank column
-- percentile is the (RANK-1)/500*100 = RANK/5
ALTER TABLE data_challenges.sp500_esg_scores
ADD score_rank bigint;

UPDATE data_challenges.sp500_esg_scores
SET score_rank = rank_table.score_rank
FROM (
	SELECT id AS rank_id, ((RANK() OVER (ORDER BY total_score NULLS FIRST))-1)/5 AS score_rank
	FROM data_challenges.sp500_esg_scores) AS rank_table
WHERE id = rank_table.rank_id;

-- added row with median score values and name='median'
INSERT INTO data_challenges.sp500_esg_scores(total_score, e_score, s_score, g_score, name)
VALUES (
	(SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY total_score) FROM data_challenges.sp500_esg_scores), 
	(SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY e_score) FROM data_challenges.sp500_esg_scores),
	(SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY s_score) FROM data_challenges.sp500_esg_scores),
	(SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY g_score) FROM data_challenges.sp500_esg_scores),
	'median');
