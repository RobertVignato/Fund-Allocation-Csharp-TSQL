USE [MunyDB02]
GO
/****** Object:  StoredProcedure [dbo].[sp_Get_AdsOnBillboardForVideo]    Script Date: 08/19/2012 16:10:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Robert Vignato
-- Create date: 07/16/2012
-- Description:	Used on VideoPage.aspx
			--  DataTable dt = advertising.Get_AdsOnBillboardForVideo(_VideoId, _IPAddress);
			--  this records a page hit in the PageHits table
			--  Added - AND (Advertisements.IsDeletedByAdvertiser = 0) 
-- =============================================
ALTER PROCEDURE [dbo].[sp_Get_AdsOnBillboardForVideo] -- v14
-- Add the INPUT parameters for the stored procedure here
	@VideoID INT 
	, @IPAddress NVARCHAR(16) 
AS
BEGIN -- 01
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here      
 DECLARE @Now DATETIME
 SET @Now = GetDate()
--------------------------------------------------------------
--------------------------------------------------------------
DECLARE @table_variable TABLE(
AdsOnBillboards_CurrentTotal MONEY -- AdsOnBillboards -- 0
, AdsOnBillboards_BidForImpression MONEY -- 1
, AdsOnBillboards_BidForClickRate MONEY -- 2
, AdsOnBillboards_MinimumBidSum MONEY -- 3 
, ContentProviderAccounts_CPAcctID INT -- ContentProviderAccounts -- 4
, ContentProviderAccounts_UserId UNIQUEIDENTIFIER -- 5
, ContentProviderAccounts_Balance MONEY -- 6 
, ContentProviderAccounts_IsActive BIT -- 7
, ContentProviderAccounts_IsVisible BIT -- 8
, ContentProviderAccounts_IsLocked BIT -- 9
, ContentProviderAccounts_IsFunded BIT -- 10
, Videos_VideoID INT -- Videos -- 11
, Videos_CPAcctID INT -- 12
, Videos_Title NVARCHAR(100) -- 13
, Videos_Description TEXT -- 14
, Videos_IsActive BIT -- 15
, Videos_IsVisible BIT -- 16
, Videos_IsVideoOwner BIT -- 17 
, Billboards_BbID INT -- Billboards -- 18
, Billboards_BbTypeID INT -- 19
, Billboards_VideoID INT -- 20
, Billboards_IsActive BIT -- 21
, Billboards_IsVisible BIT -- 22
, Billboards_IsVideoOwner BIT -- 23
, AdsOnBillboards_AdsOnBbID INT -- AdsOnBillboards -- 24
, AdsOnBillboards_AdID INT  -- 25
, AdsOnBillboards_BbID INT  -- 26
, AdsOnBillboards_IsActive BIT  -- 27
, AdsOnBillboards_IsVisible BIT  -- 28
, AdsOnBillboards_IsLocked BIT  -- 29
, AdsOnBillboards_ImpressionRate MONEY  -- 30
, AdsOnBillboards_ClickRate MONEY -- 31
, AdsOnBillboards_DateStart DATETIME -- 32
, AdsOnBillboards_DateEnd DATETIME -- 33
, Advertisements_AdID INT -- Advertisements -- 34
, Advertisements_AdvertiserAcctID INT -- 35
, Advertisements_AdName NVARCHAR(100) -- 36
, Advertisements_AdDescription TEXT -- 37
--, Advertisements_Width NCHAR(10) -- 38
--, Advertisements_Height NCHAR(10) -- 39
, Advertisements_DateStart DATETIME -- 40
, Advertisements_DateEnd DATETIME -- 41
, Advertisements_Destination_Url NVARCHAR(MAX) -- 42
, Advertisements_Alternate_Text NVARCHAR(250) -- 43
, Advertisements_ArtworkGUID NVARCHAR(50)  -- 44
, Advertisements_BLOBArtworkURL NVARCHAR(250) -- 45
, Advertisements_IsActive BIT -- 46
, Advertisements_IsVisible BIT  -- 47
--, Advertisements_IsFunded BIT -- 48
--, Advertisements_IsSuspendedByAdvertiser BIT -- 49
--, Advertisements_IsSuspendedByVideoOwner BIT -- 50
, Advertisements_IsSuspendedByUs BIT -- 51
--, Advertisements_TrackingParam01_Name NVARCHAR(50)  -- 52
--, Advertisements_TrackingParam01_Value NVARCHAR(250)  -- 53
--, Advertisements_TrackingParam02_Name NVARCHAR(50)  -- 54
--, Advertisements_TrackingParam02_Value NVARCHAR(250)  -- 55
--, Advertisements_TrackingParam03_Name NVARCHAR(50)  -- 56
--, Advertisements_TrackingParam03_Value NVARCHAR(250)  -- 57
, AdvertiserAccounts_AdvertiserAcctID INT -- AdvertiserAccounts -- 58
, AdvertiserAccounts_UserId UNIQUEIDENTIFIER  -- 59
, AdvertiserAccounts_Balance MONEY  -- 60
, AdvertiserAccounts_IsActive BIT  -- 61
, AdvertiserAccounts_IsVisible BIT  -- 62
, AdvertiserAccounts_IsLocked BIT  -- 63
, AdvertiserAccounts_IsFunded BIT  -- 64
)
--------------------------------------------------------------
INSERT @table_variable 
SELECT     
AdsOnBillboards.ImpressionRate + AdsOnBillboards.ClickRate AS CurrentTotal -- 0
, AdsOnBillboards.ImpressionRate + 0.002 AS BidForImpression -- 1
, AdsOnBillboards.ClickRate + 0.01 AS BidForClick -- 2
, AdsOnBillboards.ImpressionRate + AdsOnBillboards.ClickRate + 0.012 AS MinimumBidSum -- 0.002 more than the current top most bidder -- 3
, ContentProviderAccounts.CPAcctID AS ContentProviderAccounts_CPAcctID -- ContentProviderAccounts -- 4
, ContentProviderAccounts.UserId AS ContentProviderAccounts_UserId -- 5
, ContentProviderAccounts.Balance AS ContentProviderAccounts_Balance -- 6
, ContentProviderAccounts.IsActive AS ContentProviderAccounts_IsActive -- 7
, ContentProviderAccounts.IsVisible AS ContentProviderAccounts_IsVisible -- 8
, ContentProviderAccounts.IsLocked AS ContentProviderAccounts_IsLocked -- 9
, ContentProviderAccounts.IsFunded AS ContentProviderAccounts_IsFunded -- 10
, Videos.VideoID AS Videos_VideoID -- Videos -- 11
, Videos.CPAcctID AS Videos_CPAcctID -- 12
, Videos.Title AS Videos_Title -- 13
, Videos.Description AS Videos_Description -- 14
, Videos.IsActive AS Videos_IsActive -- 15
, Videos.IsVisible AS Videos_IsVisible -- 16
, Videos.IsVideoOwner AS Videos_IsVideoOwner -- 17
, Billboards.BbID AS Billboards_BbID -- Billboards -- 18
, Billboards.BbTypeID AS Billboards_BbTypeID -- 19
, Billboards.VideoID AS Billboards_VideoID -- 20
, Billboards.IsActive AS Billboards_IsActive -- 21
, Billboards.IsVisible AS Billboards_IsVisible -- 22
, Billboards.IsVisible AS Billboards_IsVideoOwner -- 23
, AdsOnBillboards.AdsOnBbID AS AdsOnBillboards_AdsOnBbID -- AdsOnBillboards -- 24
, AdsOnBillboards.AdID AS AdsOnBillboards_AdID -- 25
, AdsOnBillboards.BbID AS AdsOnBillboards_BbID -- 26
, AdsOnBillboards.IsActive AS AdsOnBillboards_IsActive -- 27
, AdsOnBillboards.IsVisible AS AdsOnBillboards_IsVisible -- 28
, AdsOnBillboards.IsLocked AS AdsOnBillboards_IsLocked -- 29
, AdsOnBillboards.ImpressionRate AS AdsOnBillboards_ImpressionRate -- 30
, AdsOnBillboards.ClickRate AS AdsOnBillboards_ClickRate -- 31
, AdsOnBillboards.DateStart AS AdsOnBillboards_DateStart 
, AdsOnBillboards.DateEnd AS AdsOnBillboards_DateEnd
, Advertisements.AdID AS Advertisements_AdID -- Advertisements -- 32
, Advertisements.AdvertiserAcctID AS Advertisements_AdvertiserAcctID -- 33
, Advertisements.AdName AS Advertisements_AdName -- 34
, Advertisements.AdDescription AS Advertisements_AdDescription -- 35
--, Advertisements.Width AS Advertisements_Width -- 36
--, Advertisements.Height AS Advertisements_Height -- 37
, Advertisements.DateStart AS Advertisements_DateStart -- 38
, Advertisements.DateEnd AS Advertisements_DateEnd -- 39
, Advertisements.Destination_Url AS Advertisements_Destination_Url -- 40
, Advertisements.Alternate_Text AS Advertisements_Alternate_Text -- 41
, Advertisements.ArtworkGUID AS Advertisements_ArtworkGUID -- 42
, Advertisements.BLOBArtworkURL AS Advertisements_BLOBArtworkURL -- 43
, Advertisements.IsActive AS Advertisements_IsActive -- 44
, Advertisements.IsVisible AS Advertisements_IsVisible -- 45
--, Advertisements.IsFunded AS Advertisements_IsFunded -- 46
--, Advertisements.IsSuspendedByAdvertiser AS Advertisements_IsSuspendedByAdvertiser -- 47
--, Advertisements.IsSuspendedByVideoOwner AS Advertisements_IsSuspendedByVideoOwner -- 48
, Advertisements.IsSuspendedByUs AS Advertisements_IsSuspendedByUs -- 49
--, Advertisements.TrackingParam01_Name AS Advertisements_TrackingParam01_Name -- 50
--, Advertisements.TrackingParam01_Value AS Advertisements_TrackingParam01_Value -- 51
--, Advertisements.TrackingParam02_Name AS Advertisements_TrackingParam02_Name -- 52
--, Advertisements.TrackingParam02_Value AS Advertisements_TrackingParam02_Value -- 53
--, Advertisements.TrackingParam03_Name AS Advertisements_TrackingParam03_Name -- 54
--, Advertisements.TrackingParam03_Value AS Advertisements_TrackingParam03_Value -- 55
, AdvertiserAccounts.AdvertiserAcctID AS AdvertiserAccounts_AdvertiserAcctID -- AdvertiserAccounts -- 56
, AdvertiserAccounts.UserId AS AdvertiserAccounts_UserId -- 57
, AdvertiserAccounts.Balance AS AdvertiserAccounts_Balance -- 58
, AdvertiserAccounts.IsActive AS AdvertiserAccounts_IsActive -- 59
, AdvertiserAccounts.IsVisible AS AdvertiserAccounts_IsVisible -- 60
, AdvertiserAccounts.IsLocked AS AdvertiserAccounts_IsLocked -- 61
, AdvertiserAccounts.IsFunded AS AdvertiserAccounts_IsFunded -- 62
FROM ContentProviderAccounts 
INNER JOIN Videos ON ContentProviderAccounts.CPAcctID = Videos.CPAcctID 
INNER JOIN Billboards ON Videos.VideoID = Billboards.VideoID 
INNER JOIN AdsOnBillboards ON Billboards.BbID = AdsOnBillboards.BbID 
INNER JOIN Advertisements ON AdsOnBillboards.AdID = Advertisements.AdID 
INNER JOIN AdvertiserAccounts ON Advertisements.AdvertiserAcctID = AdvertiserAccounts.AdvertiserAcctID
WHERE (Videos.VideoID = @VideoID) 
AND (AdvertiserAccounts.IsFunded = 1)  -- ============================================================================================================== MOD
AND (Advertisements.IsApproved = 1) 
AND (AdsOnBillboards.IsActive = 1) 
AND (Advertisements.IsDeletedByAdvertiser = 0) 
AND (@Now > AdsOnBillboards.DateStart) 
AND (@Now < AdsOnBillboards.DateEnd OR AdsOnBillboards.DateEnd IS NULL) 
ORDER BY CurrentTotal DESC

SELECT * FROM @table_variable 
--------------------------------------------------------------
--------------------------------------------------------------
---- Record Page Hit ----------------------------------------------------------- Took this out and created [sp_INSERT_PageHit]
--INSERT INTO [dbo].[PageHits]
--           ([VideoID]
--           ,[IPAddress])
--     VALUES 
--           (@VideoID 
--           , @IPAddress) 
--------------------------------------------------------------
--------------------------------------------------------------
-- Record Ad Impression(s) - replaces - .cs advertising.Record_AdImpression(_AdId, _VideoId, _IPAddress, _ImpressionRate); 

-- Add IF Logic for Advertiser Account Balance reduction

DECLARE @MinimumWaitPeriod INT SET @MinimumWaitPeriod = 60  
DECLARE @ElapsedTimeSinceLastHit INT 
SET @ElapsedTimeSinceLastHit = (SELECT TOP (2) DATEDIFF(second, MAX(CreatedOn), GETDATE()) 
FROM AdImpressions 
WHERE IPAddress = @IPAddress 
AND VideoID = @VideoID) -- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ------------- v13

BEGIN -- 02

IF (@ElapsedTimeSinceLastHit < @MinimumWaitPeriod)
	BEGIN -- 03
		PRINT 'No Advertiser Account Balance reduction'
	END -- 03
ELSE
	BEGIN -- 04
		--=========================================================
		-- BEGIN - Account Balance reductions
		-- BING "T SQL Exec Stored Procedure for each row"
		-- http://stackoverflow.com/questions/886293/how-do-i-execute-a-stored-procedure-once-for-each-row-returned-by-query
		
		DECLARE @AdID INT 
		DECLARE @ImpressionRate MONEY 
		DECLARE cur CURSOR LOCAL FOR 		
		--select field1, field2 from sometable where someotherfield is null 		
		SELECT     
		AdsOnBillboards.AdID
		, AdsOnBillboards.ImpressionRate
		FROM AdsOnBillboards 
		INNER JOIN Billboards ON AdsOnBillboards.BbID = Billboards.BbID 
		INNER JOIN Videos ON Billboards.VideoID = Videos.VideoID 
		INNER JOIN Advertisements ON AdsOnBillboards.AdID = Advertisements.AdID 
		INNER JOIN AdvertiserAccounts ON Advertisements.AdvertiserAcctID = AdvertiserAccounts.AdvertiserAcctID
		WHERE (Videos.VideoID = @VideoID) 
		AND (AdsOnBillboards.IsActive = 1) 
		AND (Advertisements.IsDeletedByAdvertiser = 0) 
		AND (Advertisements.IsApproved = 1) ----- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< --- Mod v14
		AND (AdvertiserAccounts.IsFunded = 1)
		OPEN cur 
			FETCH NEXT FROM cur INTO @AdID, @ImpressionRate 
			WHILE @@FETCH_STATUS = 0 BEGIN 
			--execute your sproc on each row 
			--exec uspYourSproc @field1, @field2 
			EXEC sp_UPDATE_Accounts_Impression @VideoID, @AdID, @ImpressionRate, @IPAddress --------------------------------------------------
			FETCH NEXT FROM cur INTO @AdID, @ImpressionRate 
			
	END -- 04
			 
		CLOSE cur 
		DEALLOCATE cur 		
		-- END - Account Balance reductions
		--=========================================================
		-- BEGIN - Record AdImpression
		DECLARE @table_variable2 TABLE(
		_AdsOnBillboards_AdID INT  -- 25
		, _Videos_VideoID INT -- Videos -- 11
		, _IPAddress NVARCHAR(16)  -- 
		, _AdsOnBillboards_ImpressionRate MONEY  -- 30
		, _Videos_CPAcctID INT -- 12
		, _AdvertiserAccounts_AdvertiserAcctID INT -- AdvertiserAccounts -- 56
		)
		--------------------------------------------------------------
		INSERT @table_variable2 
		SELECT     
		AdsOnBillboards.AdID
		, Videos.VideoID
		, @IPAddress 
		, AdsOnBillboards.ImpressionRate
		, Videos.CPAcctID
		, Advertisements.AdvertiserAcctID
		FROM AdsOnBillboards 
		INNER JOIN Billboards ON AdsOnBillboards.BbID = Billboards.BbID 
		INNER JOIN Videos ON Billboards.VideoID = Videos.VideoID 
		INNER JOIN Advertisements ON AdsOnBillboards.AdID = Advertisements.AdID 
		INNER JOIN AdvertiserAccounts ON Advertisements.AdvertiserAcctID = AdvertiserAccounts.AdvertiserAcctID
		WHERE (Videos.VideoID = @VideoID) 
		AND (AdsOnBillboards.IsActive = 1) 
		AND (Advertisements.IsDeletedByAdvertiser = 0) 
		AND (Advertisements.IsApproved = 1) ----- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< --- Mod v14
		AND (AdvertiserAccounts.IsFunded = 1)
		--------------------------------------------------------------
		INSERT INTO [dbo].[AdImpressions] (AdID, VideoID, IPAddress, BidRate, CPAcctID, AdvertiserAcctID) 
		SELECT 
		_AdsOnBillboards_AdID  -- 2
		, _Videos_VideoID -- 1
		, @IPAddress -- 3
		, _AdsOnBillboards_ImpressionRate  -- 4
		, _Videos_CPAcctID  -- 5
		, _AdvertiserAccounts_AdvertiserAcctID  -- 6
		FROM @table_variable2
		-- END - Record AdImpression
		--=========================================================

END -- 02
	
END
--------------------------------------------------------------
--------------------------------------------------------------


END