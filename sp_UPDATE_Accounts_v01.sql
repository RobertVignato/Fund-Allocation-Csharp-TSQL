SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Robert Vignato
-- Create date: 8/22/2012
-- Description:	Update Advertiser Account Balance
-- =============================================
ALTER PROCEDURE [dbo].[sp_UPDATE_Accounts] -- v01
	-- Add the parameters for the stored procedure here
	@VideoID INT 
	, @AdID INT 
	, @ImpressionRate MONEY 
	, @IPAddress NVARCHAR(16)
AS
BEGIN -- 01
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-------------------------- Advertiser Account ------------------------------------------------
	DECLARE @AdvertiserAcctID INT 	
	SET @AdvertiserAcctID = (SELECT AdvertiserAcctID FROM Advertisements WHERE (AdID = @AdID))
	
	DECLARE @AdvertiserAcctBalance MONEY 
	SET @AdvertiserAcctBalance = (SELECT AdvertiserAccounts.Balance 
									FROM AdvertiserAccounts 
									INNER JOIN Advertisements ON AdvertiserAccounts.AdvertiserAcctID = Advertisements.AdvertiserAcctID 
									WHERE (Advertisements.AdID = @AdID))
	-------------------------- Content Provider Account -------------------------------------------------
	DECLARE @CPAcctID INT 
	SET @CPAcctID = (SELECT CPAcctID
						FROM Videos
						WHERE (VideoID = @VideoID))
	
	DECLARE @CPAcctBalance MONEY 
	SET @CPAcctBalance = (SELECT ContentProviderAccounts.Balance 
							FROM Videos 
							INNER JOIN ContentProviderAccounts ON Videos.CPAcctID = ContentProviderAccounts.CPAcctID
							WHERE (Videos.VideoID = @VideoID))
	-------------------------- Corporate Account -------------------------------------------------
	DECLARE @CorporateAcctID INT 	
	SET @CorporateAcctID = 4 
	
	DECLARE @CorporateAcctBalance MONEY 
	SET @CorporateAcctBalance = (SELECT Balance FROM CorporateAccounts WHERE CorporateAcctID = @CorporateAcctID)
	
	----------------------------------------------------------------------------------------------
	
	DECLARE @MinimumWaitPeriod INT 
	SET @MinimumWaitPeriod = 60  
	
	DECLARE @ElapsedTimeSinceLastHit INT 
	SET @ElapsedTimeSinceLastHit = (SELECT TOP (2) DATEDIFF(second,  MAX(CreatedOn), GETDATE()) FROM AdImpressions WHERE (IPAddress = @IPAddress) AND (AdID = @AdID))
	
	IF (@ElapsedTimeSinceLastHit < @MinimumWaitPeriod)
		BEGIN 
			PRINT 'No Advertiser Account Balance reduction'
		END
	ELSE
		BEGIN -- 02
			-- If @AdvertiserAcctBalance is greater than the AdsOnBillboards.ImpressionRate, deduct the ImpressionRate from the Advertisers account and divide by 2
			IF @AdvertiserAcctBalance >= @ImpressionRate + @ImpressionRate 
			
				BEGIN
					-- UPDATE - Deduct Advertisers Account
					UPDATE AdvertiserAccounts SET Balance = (@AdvertiserAcctBalance - @ImpressionRate) WHERE AdvertiserAcctID = @AdvertiserAcctID 
					-- UPDATE - Deposit half of the AdImpressions.BidRate into the Content Providers Account
					UPDATE ContentProviderAccounts SET Balance = (@CPAcctBalance + (@ImpressionRate / 2)) WHERE CPAcctID = @CPAcctID 
					-- UPDATE - Deposit half of the AdImpressions.BidRate into the Corporate Account
					UPDATE CorporateAccounts SET Balance = (@CorporateAcctBalance + (@ImpressionRate / 2)) WHERE CorporateAcctID = @CorporateAcctID 
				END
			
			ELSE 		
				BEGIN 
					UPDATE Advertisements SET IsFunded = 0 WHERE AdID = @AdID 
				END 
		END -- 02
END -- 01