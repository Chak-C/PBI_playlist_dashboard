--## [dbo].[ImportCoreData] @ExportFilePath = 'C:\Users\Alvis\Desktop\Music\BI\Extraction\Output\data.csv'

--## [dbo].[ImportFeatureData] @ExportFilePath = 'C:\Users\Alvis\Desktop\Music\BI\Extraction\Output\feature_data2.csv'
--##  [dbo].[IMPORTKEYS]
UPDATE [dbo].[Tracks]
SET Artist = REPLACE(Artist, ';',''),
	[Contributing Artist] =  REPLACE(REPLACE([Contributing Artist], '/', ','), ';', ',')

-- Create comparison table for official title and artist names
DROP TABLE IF EXISTS [TrackData].ComparisonTable;

SELECT a.Title, a.Artist as [Artist], b.[Spotify Title], b.[Spotify Artist] as [Spotify Artist]
INTO [TrackData].ComparisonTable
FROM [dbo].[Tracks] a
INNER JOIN
[dbo].[Dynamics] b
ON a.[Title] = b.[Title]
;

-- Isolate rows that are not identical
SELECT * FROM [TrackData].ComparisonTable where Artist IS NULL OR NOT Artist = [Spotify Artist];

-- manually select original artist names from the select statement above to exempt them from replacement
-- (add N for chinese/japanese/korean characters, Unicode string literal)
DELETE FROM [TrackData].ComparisonTable
WHERE [Artist] IN ('DECO*27','Chinozo','singtur','wowaka','Linked Horizon','Aiobahn','JJ Lin','MyGO', N'P丸様', 'Chainsmokers');

-- Remove identical rows: If not ran results in loop when running function
-- Note, if any artists are a substring of it's sportify artist, either remove them or use the alternative method instead.
DELETE FROM [TrackData].ComparisonTable
WHERE [Artist] = [Spotify Artist]

-- Update the master table with official names (for non-null)
UPDATE [dbo].[Tracks]
SET 
    [Artist] = [TrackData].[REPLACE_ARTIST]([Artist]),
    [Contributing Artist] = [TrackData].[REPLACE_ARTIST]([Contributing Artist])
;

UPDATE [dbo].[Tracks]
SET [Artist] = b.[Spotify Artist]
FROM [dbo].[Tracks] a
INNER JOIN (
	SELECT *
	FROM [TrackData].[ComparisonTable]
	WHERE Artist IS NULL
) b
ON a.Title = b.Title

/* Alternative solution:
Without deleting from the table, run this instead, but requires inner join instead and does not handle replacement of contributing artists.

UPDATE [dbo].[Tracks]
SET [Artist] = b.[Spotify Artist]
FROM [dbo].[Tracks] a
INNER JOIN (
	SELECT Title, Artist, [Spotify Artist] FROM [TrackData].ComparisonTable 
	WHERE Artist IS NULL OR (
		NOT Artist = [Spotify Artist] 
		AND ARTIST NOT IN ('DECO*27','Chinozo','singtur','wowaka','Linked Horizon','Aiobahn','JJ Lin')
		)
) b
ON a.Title = b.Title
*/

-- END OF CLEANING ARTIST NAMES
-- CLEANING LANGUAGE

SELECT [Artist], [Language]
  FROM (
	SELECT DISTINCT [Artist] 
	FROM [dbo].[Tracks]
) artist
CROSS APPLY (
	SELECT TOP 1 [Language], COUNT(*) AS n
	FROM [dbo].[Tracks] lan
	WHERE artist.[Artist] = lan.[Artist]
	GROUP BY [Language]
	ORDER BY COUNT(*) DESC
) languages

-- Run replace language for each mismatch (MANUAL), alternatively use excel (not provided)

[TrackData].[REPLACE_LANGUAGE] @artist = N'Mao Buyi', @language = 'Chinese'

WITH sub AS (
	SELECT [Artist], [Language]
	  FROM (
		SELECT DISTINCT [Artist] 
		FROM [dbo].[Tracks]
	) artist
	CROSS APPLY (
		SELECT TOP 1 [Language], COUNT(*) AS n
		FROM [dbo].[Tracks] lan
		WHERE artist.[Artist] = lan.[Artist]
		GROUP BY [Language]
		ORDER BY COUNT(*) DESC
	) languages
)
UPDATE core
SET [Language] = sub.[Language]
FROM [dbo].[Tracks] core
INNER JOIN sub ON core.[Artist] = sub.[Artist]

-- END OF LANGUAGE CLEANING
-- ClEANING KEYS

-- Run check if corrected keys table is imported:
/*
WITH CorrectedKeys_RN AS (
    SELECT *,
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNumber
    FROM TrackData.CorrectedKeys
),
Tracks_RN AS (
    SELECT *,
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNumber
    FROM dbo.Tracks
)
SELECT a.[Key], b.[Key] 
FROM CorrectedKeys_RN a
INNER JOIN Tracks_RN b ON a.RowNumber = b.RowNumber
WHERE a.[Key] != b.[Key];

-- update statement
WITH CorrectedKeys_RN AS (
    SELECT *,
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNumber
    FROM TrackData.CorrectedKeys
), Tracks_RN AS (
    SELECT *,
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNumber
    FROM dbo.Tracks
), Correct_Keys AS (
	SELECT a.[Title], b.[Key]
	FROM CorrectedKeys_RN a
	INNER JOIN Tracks_RN b ON a.RowNumber = b.RowNumber
	WHERE a.[Key] != b.[Key]
)
UPDATE core
SET [Key] = sub.[Key] 
FROM [dbo].[Tracks] core
INNER JOIN Correct_keys sub
ON core.[Title] = sub.[Title]
*/

-- END OF CLEANING KEYS
-- Cleaning other metadata

SELECT * FROM [dbo].[Tracks] WHERE [Year] IS NULL OR [Genre] IS NULL OR [Highest Note] IS NULL

UPDATE [dbo].[Tracks]
SET [Genre] = 'Music'
FROM [dbo].[Tracks]
WHERE [Title] = 'Nightcall'

UPDATE [dbo].[Tracks]
SET [Year] = '2019'
FROM [dbo].[Tracks]
WHERE [Title] = N'暗恋是一个人的事情'

-- END OF CLEANING

-- Merge for the final dataset
SELECT t.*, d.[Acousticness], d.[Danceability], d.[Energy], d.[Instrumentalness], d.[Liveliness], d.[Speechiness], d.[Valence]
INTO [dbo].[FinalDataset]
FROM [dbo].[Tracks] t
INNER JOIN [dbo].[Dynamics] d
ON t.[Title] = d.[Title]


/*
--Highest key shifter (make it adjustable)

UPDATE dbo.FinalDataset
SET [Highest Note] =
    CASE 
        WHEN [Highest Note] = 'E3' THEN 'G#3'
        WHEN [Highest Note] = 'F3' THEN 'A3'
        WHEN [Highest Note] = 'F#3' THEN 'A#3'
        WHEN [Highest Note] = 'G3' THEN 'B3'
        WHEN [Highest Note] = 'G#3' THEN 'C4'
        WHEN [Highest Note] = 'A3' THEN 'C#4'
        WHEN [Highest Note] = 'A#3' THEN 'D4'
        WHEN [Highest Note] = 'B3' THEN 'D#4'
        WHEN [Highest Note] = 'C4' THEN 'E4'
        WHEN [Highest Note] = 'C#4' THEN 'F4'
        WHEN [Highest Note] = 'D4' THEN 'F#4'
        WHEN [Highest Note] = 'D#4' THEN 'G4'
        WHEN [Highest Note] = 'E4' THEN 'G#4'
        WHEN [Highest Note] = 'F4' THEN 'A4'
        WHEN [Highest Note] = 'F#4' THEN 'A#4'
        WHEN [Highest Note] = 'G4' THEN 'B4'
        WHEN [Highest Note] = 'G#4' THEN 'C5'
        WHEN [Highest Note] = 'A4' THEN 'C#5'
        WHEN [Highest Note] = 'A#4' THEN 'D5'
        WHEN [Highest Note] = 'B4' THEN 'D#5'
        WHEN [Highest Note] = 'C5' THEN 'E5'
        WHEN [Highest Note] = 'C#5' THEN 'F5'
        WHEN [Highest Note] = 'D5' THEN 'F#5'
        WHEN [Highest Note] = 'D#5' THEN 'G5'
		WHEN [Highest Note] = 'E5' THEN 'G#5'
		WHEN [Highest Note] = 'F5' THEN 'A5'
		WHEN [Highest Note] = 'F#5' THEN 'A#5'
        ELSE [Highest Note] -- If the note is not in the lookup table, leave it unchanged
    END;
*/

-- run after sorting the correct vocals of artist (bands)
[dbo].[ImportArtistData] @ExportFilePath = 'C:\Users\Alvis\Desktop\Music\BI\Extraction\Output\artist.csv' 

ALTER TABLE FinalDataset
ADD [Gender] nvarchar(40) null

UPDATE core
SET core.[Gender] = sub.[Gender]
FROM [dbo].[FinalDataset] core
INNER JOIN [TrackData].[Artist] sub
ON core.Artist = sub.Artist

--
UPDATE core
SET core.[Gender] = 'Male'
FROM [dbo].[FinalDataset] core
WHERE title = N'メリーゴーランド'

SELECT TOP (1000) title, artist, [contributing artist], gender
  FROM [Track_BI].[dbo].[FinalDataset]
--
