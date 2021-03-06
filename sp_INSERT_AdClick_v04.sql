USE [xyz]
GO
/****** Object:  StoredProcedure [dbo].[sp_INSERT_AdClick]  ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Robert Vignato
-- Description:	Record a click event to the AdClick table and run a TRIGGER that 
-- deducts the Advertises account and credits the Content Prodver and Corporate accounts.
-- =============================================
ALTER PROCEDURE [dbo].[sp_INSERT_AdClick] -- v04
-- Add the INPUT parameters for the stored procedure here
	@AdID INT 
	, @VideoID INT
	, @IPAddress NVARCHAR(16)
AS
BEGIN -- 01
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here 
    
    
DECLARE @MinimumWaitPeriod INT SET @MinimumWaitPeriod = 60  
DECLARE @ElapsedTimeSinceLastHit INT 
SET @ElapsedTimeSinceLastHit = (SELECT TOP (2) DATEDIFF(second, MAX(CreatedOn), GETDATE()) 
FROM AdClicks 
WHERE IPAddress = @IPAddress)
BEGIN -- 02
IF (@ElapsedTimeSinceLastHit < @MinimumWaitPeriod)
	BEGIN
		PRINT 'No Advertiser Account Balance reduction'
	END
ELSE
	BEGIN -- 03
		--=========================================================
		-- BEGIN - Account Balance reductions
		DECLARE @ClickRate MONEY 
		SET @ClickRate = (SELECT 
			AdsOnBillboards.ClickRate AS ClickRate
			FROM AdsOnBillboards 
			INNER JOIN Billboards ON AdsOnBillboards.BbID = Billboards.BbID 
			INNER JOIN Videos ON Billboards.VideoID = Videos.VideoID 
			INNER JOIN Advertisements ON AdsOnBillboards.AdID = Advertisements.AdID
			WHERE (Videos.VideoID = @VideoID) AND (AdsOnBillboards.AdID = @AdID)
			AND (Advertisements.IsFunded = 1) 
			AND (AdsOnBillboards.IsActive = 1))
			
			EXEC sp_UPDATE_Accounts_Click @VideoID, @AdID, @ClickRate, @IPAddress --------------------------------------------
			
			--END
		-- END - Account Balance reductions
		
		--=========================================================
		
		-- BEGIN - Record AdClick
		
			--BEGIN 
			DECLARE @table_variable01 
			TABLE(
				AdsOnBillboards_AdID INT -- 1
				, Videos_VideoID INT -- 2
				, IPAddress NVARCHAR(16) -- 3
				, AdsOnBillboards_ClickRate MONEY -- 4
				, Videos_CPAcctID INT -- 5
				, AdvertiserAccounts_AdvertiserAcctID INT -- 6
			)
			-------------------------------------------------------------
		   -- Look up the CPAcctID
		   -- Look up the AdvertiserAcctID
		   INSERT @table_variable01
		   SELECT 
				AdsOnBillboards.AdID -- 1
				, Videos.VideoID -- 2
				, @IPAddress -- 3
				, AdsOnBillboards.ClickRate -- 4
				, Videos.CPAcctID -- 5
				, Advertisements.AdvertiserAcctID -- 6
			FROM AdsOnBillboards 
			INNER JOIN Billboards ON AdsOnBillboards.BbID = Billboards.BbID 
			INNER JOIN Videos ON Billboards.VideoID = Videos.VideoID 
			INNER JOIN Advertisements ON AdsOnBillboards.AdID = Advertisements.AdID
			WHERE (Videos.VideoID = @VideoID) 
			AND (AdsOnBillboards.AdID = @AdID) 
			AND (Advertisements.IsFunded = 1) 
			--AND (Advertisements.IsActive = 1) 
			AND (AdsOnBillboards.IsActive = 1) 
			---------------------------------------------------------------
		   -- INSERT INTO the AdClicks Table
			INSERT INTO [dbo].[AdClicks] (AdID, VideoID,  IPAddress, BidRate, CPAcctID, AdvertiserAcctID) 
			SELECT 
			AdsOnBillboards_AdID -- 1
			, Videos_VideoID -- 2
			, @IPAddress -- 3
			, AdsOnBillboards_ClickRate -- 4
			, Videos_CPAcctID -- 5
			, AdvertiserAccounts_AdvertiserAcctID -- 6
			FROM @table_variable01
			
			-- END - Record AdClick
			--=========================================================
			
		END -- 03
	END -- 02
END -- 01