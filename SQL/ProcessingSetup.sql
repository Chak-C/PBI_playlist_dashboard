IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'TrackData')
	EXEC ('CREATE SCHEMA TrackData');
    GO     
;

IF OBJECT_ID ('dbo.ImportFeatureData', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[ImportFeatureData]
;

IF OBJECT_ID ('dbo.ImportCoreData', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[ImportCoreData]
;

IF OBJECT_ID ('dbo.ImportKeys', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[IMPORTKEYS]
;

IF OBJECT_ID ('dbo.ImportArtistData', 'P' IS NOT NULL)
    DROP PROCEDURE [dbo].[ImportArtistData]
;

GO

CREATE PROCEDURE [dbo].[ImportFeatureData]
(
    @ExportFilePath NVARCHAR(500) -- example: 'C:\Users\Alvis\Desktop\Music\BI\feature_data2.csv' 
)
AS
    DECLARE @EncodingType NVARCHAR(5) = '65001' -- utf-8
    DECLARE @wdQueryString NVARCHAR(MAX)

    DROP TABLE IF EXISTS [dbo].[Dynamics]
    ;

    CREATE TABLE [dbo].[Dynamics] --[dbo].[Tracks]
    (
        [Title] [NVARCHAR](100) NOT NULL,
        [Spotify Title] [NVARCHAR](100) NULL,
        [Spotify Artist] [NVARCHAR](100) NULL,
        [Acousticness] FLOAT NULL,
        [Danceability] FLOAT NULL,
        [Energy] FLOAT NULL,
        [Instrumentalness] FLOAT NULL,
        [Liveliness] FLOAT NULL,
        [Speechiness] FLOAT NULL,
        [Valence] FLOAT NULL
    );

    SET @wdQueryString =
        'BULK INSERT [dbo].[Dynamics]
        FROM ''' + @ExportFilePath + '''
        WITH (
            CODEPAGE = ''' + @EncodingType + ''',
            FORMAT = ''CSV'',
            FIRSTROW = 2,
            MAXERRORS = 2,
            FIELDTERMINATOR = '','', 
            ROWTERMINATOR = ''\n''
        );
    '

    EXEC sp_executesql @wdQueryString
    PRINT 'Dynamics Table loaded'
; -- Closes the ImportFeatureData stored procedure

GO


CREATE PROCEDURE [dbo].[ImportCoreData]
(
    @ExportFilePath NVARCHAR(500) -- example: 'C:\Users\Alvis\Desktop\Music\BI\Extraction\Output\feature_data2.csv' 
)
AS
    DECLARE @EncodingType NVARCHAR(5) = '65001' -- delcared already in SQRL processing
    DECLARE @wdQueryString NVARCHAR(MAX) -- declared already

    DROP TABLE IF EXISTS [dbo].[Tracks]
    ;

    CREATE TABLE [dbo].[Tracks] --[dbo].[Tracks]
    (
        [Title] [NVARCHAR](100) NULL,
        [Artist] [NVARCHAR](100) NULL,
        [Contributing Artist] [NVARCHAR](100) NULL,
        [Year] [NVARCHAR](100) NULL,
        [Genre] [NVARCHAR](100) NULL,
        [Duration] [NVARCHAR](100) NULL,
        [Size] INT NULL,
        [Bit rate] INT NULL,
        [Created Date] DATETIME2 NULL,
        [Last Modified Date] DATETIME2 NULL,
        [Key] [NVARCHAR](100) NULL,
		[Tempo] INT NULL,
        [Language] [NVARCHAR](100) NULL,
        [Lowest Note] [NVARCHAR](100) NULL,
        [Highest Note] [NVARCHAR](100) NULL,
        [Mode Note] [NVARCHAR](100) NULL,
        C2 INT NULL,
        C#2 INT NULL,
        D2 INT NULL,
        D#2 INT NULL,
        E2 INT NULL,
        F2 INT NULL,
        F#2 INT NULL,
        G2 INT NULL,
        G#2 INT NULL,
        A2 INT NULL,
        A#2 INT NULL,
        B2 INT NULL,
        C3 INT NULL,
        C#3 INT NULL,
        D3 INT NULL,
        D#3 INT NULL,
        E3 INT NULL,
        F3 INT NULL,
        F#3 INT NULL,
        G3 INT NULL,
        G#3 INT NULL,
        A3 INT NULL,
        A#3 INT NULL,
        B3 INT NULL,
        C4 INT NULL,
        C#4 INT NULL,
        D4 INT NULL,
        D#4 INT NULL,
        E4 INT NULL,
        F4 INT NULL,
        F#4 INT NULL,
        G4 INT NULL,
        G#4 INT NULL,
        A4 INT NULL,
        A#4 INT NULL,
        B4 INT NULL,
        C5 INT NULL,
        C#5 INT NULL,
        D5 INT NULL,
        D#5 INT NULL,
        E5 INT NULL,
        F5 INT NULL,
        F#5 INT NULL,
        G5 INT NULL,
        G#5 INT NULL,
        A5 INT NULL,
        A#5 INT NULL,
        B5 INT NULL,
        C6 INT NULL,
        C#6 INT NULL,
        D6 INT NULL,
        D#6 INT NULL,
        E6 INT NULL
    )


    SET @wdQueryString =
        'BULK INSERT [dbo].[Tracks]
        FROM ''' + @ExportFilePath + '''
        WITH (
            CODEPAGE = ''' + @EncodingType + ''',
            FORMAT = ''CSV'',
            FIRSTROW = 2,
            MAXERRORS = 2,
            FIELDTERMINATOR = '','', 
            ROWTERMINATOR = ''\n''
        );
    '

    EXEC sp_executesql @wdQueryString
    PRINT 'Core Table loaded'
; -- Closes the ImportCoreData stored procedure

GO

CREATE PROCEDURE [dbo].[IMPORTKEYS]
AS
    DECLARE @EncodingType NVARCHAR(5) = '65001' -- utf-8
    DECLARE @wdQueryString NVARCHAR(MAX)

    DROP TABLE IF EXISTS [TrackData].[CorrectedKeys]
    ;

    CREATE TABLE [TrackData].[CorrectedKeys] --[dbo].[Tracks]
    (
        [Title] [NVARCHAR](4000) NOT NULL,
        [Key] [NVARCHAR](100) NULL,
        [Tempo] FLOAT NULL
    );

    SET @wdQueryString =
        'BULK INSERT [TrackData].[CorrectedKeys]
        FROM ''C:\Users\Alvis\Desktop\Music\BI\Extraction\output\corrected_keys.csv''
        WITH (
            CODEPAGE = ''' + @EncodingType + ''',
            FORMAT = ''CSV'',
            FIRSTROW = 2,
            MAXERRORS = 2,
            FIELDTERMINATOR = '','', 
            ROWTERMINATOR = ''\n''
        );
    '

    EXEC sp_executesql @wdQueryString
; -- Close Procedure IMPORTKEYS

GO

CREATE PROCEDURE [dbo].[ImportArtistData]
(
    @ExportFilePath NVARCHAR(500) -- example: 'C:\Users\Alvis\Desktop\Music\BI\Extraction\Output\artist.csv' 
)
AS
    DECLARE @EncodingType NVARCHAR(5) = '65001' -- utf-8 format
    DECLARE @wdQueryString NVARCHAR(MAX)

    DROP TABLE IF EXISTS [TrackData].[Artist]

    CREATE TABLE [TrackData].[Artist] (
        Artist NVARCHAR(255) NULL,
        Gender NVARCHAR(100) NULL
    )

    SET @wdQueryString = '
        BULK INSERT [TrackData].[Artist]
        FROM ''' + @ExportFilePath + '''
        WITH (
            CODEPAGE = ''' + @EncodingType + ''',
            FORMAT = ''CSV'',
            FIRSTROW = 2,
            MAXERRORS = 2,
            FIELDTERMINATOR = '','', 
            ROWTERMINATOR = ''\n''
        );
    '

    EXEC sp_executesql @wdQueryString
; -- End procedure

GO

CREATE PROCEDURE [TrackData].[REPLACE_LANGUAGE] (
	@artist NVARCHAR(255),
	@language NVARCHAR(255)
)
AS
	UPDATE [dbo].[Tracks]
	SET
		[Language] = @language
	WHERE [Artist] = @artist
; -- Close procedure

GO

DROP TABLE IF EXISTS [TrackData].[ComparisonTable]
CREATE TABLE [TrackData].[ComparisonTable] (
    [Artist] NVARCHAR(4000),
    [Spotify Artist] NVARCHAR(4000)
)

GO

CREATE FUNCTION [TrackData].[REPLACE_ARTIST] (
    @text NVARCHAR(4000)    
)
RETURNS NVARCHAR(4000)
AS
BEGIN
    DECLARE @Artist NVARCHAR(50) -- Change CHAR limit as required
    DECLARE @SpotifyName NVARCHAR(50)

    SELECT TOP 1 @Artist = TRIM([Artist]), @SpotifyName = TRIM([Spotify Artist])
    FROM [TrackData].[ComparisonTable]
    WHERE CHARINDEX([Artist], @text) > 0
    ORDER BY LEN([Artist]) DESC

    WHILE @Artist IS NOT NULL
    BEGIN
        SET @text = REPLACE(@text, @Artist, @SpotifyName)
        
        -- Use set because select does not set variables to NULL if they were not prior to select statement
        SET @Artist = (SELECT TOP 1 TRIM([Artist]) FROM [TrackData].[ComparisonTable] WHERE CHARINDEX([Artist], @text) > 0 ORDER BY LEN([Artist]) DESC)
        SET @SpotifyName = (SELECT TOP 1 TRIM([Spotify Artist]) FROM [TrackData].[ComparisonTable] WHERE CHARINDEX([Artist], @text) > 0 ORDER BY LEN([Artist]) DESC)       
    END

    RETURN @text
END
