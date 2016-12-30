SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Robert Vignato
-- Description:	Update Account Balance
-- =============================================
CREATE PROCEDURE [dbo].[sp_UPDATE_Accounts_Impression_BrowsePage] -- v01
	-- Add the parameters for the stored procedure here
	@BbID INT 
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
					
					-- UPDATE - Deposit ALL of the AdImpressions.BidRate into the Corporate Account
					UPDATE CorporateAccounts SET Balance = (@CorporateAcctBalance + @ImpressionRate) WHERE CorporateAcctID = @CorporateAcctID 
				END
			
			ELSE 		
				BEGIN 
					UPDATE Advertisements SET IsFunded = 0 WHERE AdID = @AdID 
				END 
		END -- 02
END -- 01