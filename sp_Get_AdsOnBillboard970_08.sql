USE [xyz]
GO
/****** Object:  StoredProcedure [dbo].[sp_Get_AdsOnBillboard970]    Script Date: 08/19/2012 16:10:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Robert Vignato
-- Description:	Used on SearchResults.aspx

-- =============================================
ALTER PROCEDURE [dbo].[sp_Get_AdsOnBillboard970] -- v08
-- Add the INPUT parameters for the stored procedure here
	@BbID INT
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
, Billboards_BbID INT -- Billboards -- 04
, Billboards_BbTypeID INT -- 05
, Billboards_VideoID INT -- 06
, Billboards_IsActive BIT -- 07
, Billboards_IsVisible BIT -- 08
, Billboards_IsVideoOwner BIT -- 09
, AdsOnBillboards_AdsOnBbID INT -- AdsOnBillboards -- 10
, AdsOnBillboards_AdID INT  -- 11
, AdsOnBillboards_BbID INT  -- 12
, AdsOnBillboards_IsActive BIT  -- 13
, AdsOnBillboards_IsVisible BIT  -- 14
, AdsOnBillboards_IsLocked BIT  -- 15
, AdsOnBillboards_ImpressionRate MONEY  -- 16
, AdsOnBillboards_ClickRate MONEY -- 17
, AdsOnBillboards_DateStart DATETIME -- 18
, AdsOnBillboards_DateEnd DATETIME -- 19
, Advertisements_AdID INT -- Advertisements -- 20
, Advertisements_AdvertiserAcctID INT -- 21
, Advertisements_AdName NVARCHAR(100) -- 22
, Advertisements_AdDescription TEXT -- 23
, Advertisements_DateStart DATETIME -- 24
, Advertisements_DateEnd DATETIME -- 25
, Advertisements_Destination_Url NVARCHAR(MAX) -- 26
, Advertisements_Alternate_Text NVARCHAR(250) -- 27
, Advertisements_ArtworkGUID NVARCHAR(50)  -- 28
, Advertisements_BLOBArtworkURL NVARCHAR(250) -- 29
, Advertisements_IsActive BIT -- 30
, Advertisements_IsVisible BIT  -- 31
, Advertisements_IsSuspendedByUs BIT -- 32
, AdvertiserAccounts_AdvertiserAcctID INT -- AdvertiserAccounts -- 33
, AdvertiserAccounts_UserId UNIQUEIDENTIFIER  -- 34
, AdvertiserAccounts_Balance MONEY  -- 35
, AdvertiserAccounts_IsActive BIT  -- 36
, AdvertiserAccounts_IsVisible BIT  -- 37
, AdvertiserAccounts_IsLocked BIT  -- 38
, AdvertiserAccounts_IsFunded BIT  -- 39
)
--------------------------------------------------------------
INSERT @table_variable 
SELECT TOP 1 
AdsOnBillboards.ImpressionRate + AdsOnBillboards.ClickRate AS CurrentTotal
, AdsOnBillboards.ImpressionRate + 0.002 AS BidForImpression
, AdsOnBillboards.ClickRate + 0.01 AS BidForClick
, AdsOnBillboards.ImpressionRate + AdsOnBillboards.ClickRate + 0.012 AS MinimumBidSum
, Billboards.BbID AS Billboards_BbID
, Billboards.BbTypeID AS Billboards_BbTypeID
, Billboards.VideoID AS Billboards_VideoID
, Billboards.IsActive AS Billboards_IsActive
, Billboards.IsVisible AS Billboards_IsVisible
, Billboards.IsVisible AS Billboards_IsVideoOwner
, AdsOnBillboards.AdsOnBbID AS AdsOnBillboards_AdsOnBbID
, AdsOnBillboards.AdID AS AdsOnBillboards_AdID
, AdsOnBillboards.BbID AS AdsOnBillboards_BbID
, AdsOnBillboards.IsActive AS AdsOnBillboards_IsActive
, AdsOnBillboards.IsVisible AS AdsOnBillboards_IsVisible
, AdsOnBillboards.IsLocked AS AdsOnBillboards_IsLocked
, AdsOnBillboards.ImpressionRate AS AdsOnBillboards_ImpressionRate
, AdsOnBillboards.ClickRate AS AdsOnBillboards_ClickRate
, AdsOnBillboards.DateStart AS AdsOnBillboards_DateStart 
, AdsOnBillboards.DateEnd AS AdsOnBillboards_DateEnd
, Advertisements.AdID AS Advertisements_AdID
, Advertisements.AdvertiserAcctID AS Advertisements_AdvertiserAcctID
, Advertisements.AdName AS Advertisements_AdName
, Advertisements.AdDescription AS Advertisements_AdDescription
, Advertisements.DateStart AS Advertisements_DateStart
, Advertisements.DateEnd AS Advertisements_DateEnd
, Advertisements.Destination_Url AS Advertisements_Destination_Url
, Advertisements.Alternate_Text AS Advertisements_Alternate_Text
, Advertisements.ArtworkGUID AS Advertisements_ArtworkGUID
, Advertisements.BLOBArtworkURL AS Advertisements_BLOBArtworkURL
, Advertisements.IsActive AS Advertisements_IsActive
, Advertisements.IsVisible AS Advertisements_IsVisible
, Advertisements.IsSuspendedByUs AS Advertisements_IsSuspendedByUs
, AdvertiserAccounts.AdvertiserAcctID AS AdvertiserAccounts_AdvertiserAcctID
, AdvertiserAccounts.UserId AS AdvertiserAccounts_UserId
, AdvertiserAccounts.Balance AS AdvertiserAccounts_Balance
, AdvertiserAccounts.IsActive AS AdvertiserAccounts_IsActive
, AdvertiserAccounts.IsVisible AS AdvertiserAccounts_IsVisible
, AdvertiserAccounts.IsLocked AS AdvertiserAccounts_IsLocked
, AdvertiserAccounts.IsFunded AS AdvertiserAccounts_IsFunded
FROM Billboards 
INNER JOIN AdsOnBillboards ON Billboards.BbID = AdsOnBillboards.BbID 
INNER JOIN Advertisements ON AdsOnBillboards.AdID = Advertisements.AdID 
INNER JOIN AdvertiserAccounts ON Advertisements.AdvertiserAcctID = AdvertiserAccounts.AdvertiserAcctID
WHERE (AdvertiserAccounts.IsFunded = 1) 
AND (Advertisements.IsApproved = 1)  
AND (AdsOnBillboards.IsActive = 1)  
AND (Billboards.BbID = @BbID) 
AND (@Now > AdsOnBillboards.DateStart) 
AND (@Now < AdsOnBillboards.DateEnd OR AdsOnBillboards.DateEnd IS NULL) 
ORDER BY CurrentTotal DESC

SELECT * FROM @table_variable 
--------------------------------------------------------------
--------------------------------------------------------------
-- Record Page Hit - <<< Turned off because this SP is for the Search Results Page
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

DECLARE @AdID INT 
SET @AdID = (SELECT TOP (1) AdsOnBillboards.AdID
				FROM AdsOnBillboards 
				INNER JOIN Billboards ON AdsOnBillboards.BbID = Billboards.BbID 
				INNER JOIN Advertisements ON AdsOnBillboards.AdID = Advertisements.AdID 
				INNER JOIN AdvertiserAccounts ON Advertisements.AdvertiserAcctID = AdvertiserAccounts.AdvertiserAcctID
				WHERE (Billboards.BbID = @BbID) 
				AND (Advertisements.IsApproved = 1) 
				AND (AdsOnBillboards.IsActive = 1) 
				AND (AdvertiserAccounts.IsFunded = 1) 
				ORDER BY AdsOnBillboards.ImpressionRate DESC)

DECLARE @ImpressionRate MONEY 
SET @ImpressionRate = (SELECT TOP (1) AdsOnBillboards.ImpressionRate
				FROM AdsOnBillboards 
				INNER JOIN Billboards ON AdsOnBillboards.BbID = Billboards.BbID 
				INNER JOIN Advertisements ON AdsOnBillboards.AdID = Advertisements.AdID 
				INNER JOIN AdvertiserAccounts ON Advertisements.AdvertiserAcctID = AdvertiserAccounts.AdvertiserAcctID
				WHERE (Billboards.BbID = @BbID) 
				AND (Advertisements.IsApproved = 1) 
				AND (AdsOnBillboards.IsActive = 1) 
				AND (AdvertiserAccounts.IsFunded = 1) 
				ORDER BY AdsOnBillboards.ImpressionRate DESC) 


DECLARE @MinimumWaitPeriod INT SET @MinimumWaitPeriod = 60  
DECLARE @ElapsedTimeSinceLastHit INT 
SET @ElapsedTimeSinceLastHit = (SELECT TOP (2) DATEDIFF(second, MAX(CreatedOn), GETDATE()) -- This won't work because it won't record another Ad hit on another page within the time limit
FROM AdImpressions 
WHERE IPAddress = @IPAddress 
AND BbID = @BbID -- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< ------------- v07
AND AdID = @AdID)

BEGIN -- 02

IF (@ElapsedTimeSinceLastHit < @MinimumWaitPeriod)
	BEGIN -- 03
		PRINT 'No Advertiser Account Balance reduction'
	END -- 03
ELSE
	BEGIN -- 04
		--=========================================================
		-- BEGIN - Account Balance reductions
		
		EXEC sp_UPDATE_Accounts_Impression_SearchResultsPage @BbID, @AdID, @ImpressionRate, @IPAddress 		
						
		-- END - Account Balance reductions
		--=========================================================
		-- BEGIN - Record AdImpression
		DECLARE @table_variable2 TABLE(
		_AdsOnBillboards_AdID INT  -- 11
		, _IPAddress NVARCHAR(16) 
		, _AdsOnBillboards_ImpressionRate MONEY  -- 16
		, _AdvertiserAccounts_AdvertiserAcctID INT -- 19
		, _AdsOnBillboards_BbID INT -- <<<<<<<<<<<<<<<<<<<<<<<<<<<< ------------- v07
		)
		--------------------------------------------------------------
		INSERT @table_variable2
		SELECT TOP (1) 
		AdsOnBillboards.AdID
		, @IPAddress 
		, AdsOnBillboards.ImpressionRate
		, Advertisements.AdvertiserAcctID
		, AdsOnBillboards.BbID  -- <<<<<<<<<<<<<<<<<<<<<<<<<<<< ------------- v07
		FROM AdsOnBillboards 
		INNER JOIN Advertisements ON AdsOnBillboards.AdID = Advertisements.AdID 
		INNER JOIN AdvertiserAccounts ON Advertisements.AdvertiserAcctID = AdvertiserAccounts.AdvertiserAcctID
		WHERE (AdsOnBillboards.BbID = @BbID) 
		AND (AdsOnBillboards.IsActive = 1) 
		AND (AdvertiserAccounts.IsFunded = 1)
		AND (Advertisements.IsApproved = 1) ----- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< --- Mod v08
		ORDER BY AdsOnBillboards.ImpressionRate DESC 
		--------------------------------------------------------------
		INSERT INTO [dbo].[AdImpressions] (AdID, IPAddress, BidRate, AdvertiserAcctID, BbID)  -- <<<<<<<<<<<<<<<<<<<<<<<<<<<< ------------- v07 
		SELECT 
		_AdsOnBillboards_AdID 
		, @IPAddress 
		, _AdsOnBillboards_ImpressionRate 
		, _AdvertiserAccounts_AdvertiserAcctID 
		, _AdsOnBillboards_BbID  -- <<<<<<<<<<<<<<<<<<<<<<<<<<<< ------------- v07
		FROM @table_variable2
		-- END - Record AdImpression
		--=========================================================

	END -- 04
END -- 02
	
END
--------------------------------------------------------------
--------------------------------------------------------------
