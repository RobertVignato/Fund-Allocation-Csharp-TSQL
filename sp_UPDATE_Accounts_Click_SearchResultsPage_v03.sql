SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Robert Vignato
-- Description:	Update Account Balance
-- =============================================
ALTER PROCEDURE [dbo].[sp_UPDATE_Accounts_Click_SearchResultsPage] -- v03
	-- Add the parameters for the stored procedure here
	@AdID INT 
	, @IPAddress NVARCHAR(16)
AS
BEGIN -- 01
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @ClickRate MONEY 
	SET @ClickRate = (SELECT ClickRate FROM AdsOnBillboards WHERE AdID = @AdID)
	
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
	SET @ElapsedTimeSinceLastHit = (SELECT TOP (2) DATEDIFF(second,  MAX(CreatedOn), GETDATE()) FROM AdClicks WHERE (IPAddress = @IPAddress) AND (AdID = @AdID))
	
	
	IF (@ElapsedTimeSinceLastHit < @MinimumWaitPeriod)
		BEGIN 
			PRINT 'No Advertiser Account Balance reduction'
		END
	ELSE
		BEGIN -- 02
			-- If @AdvertiserAcctBalance is greater than the AdsOnBillboards.ClickRate, deduct the ClickRate from the Advertisers account and divide by 2
			IF @AdvertiserAcctBalance >= @ClickRate + @ClickRate 
			
				BEGIN
					-- Deduct Advertisers Account
					UPDATE AdvertiserAccounts 
						SET Balance = (@AdvertiserAcctBalance - @ClickRate) 
						WHERE AdvertiserAcctID = @AdvertiserAcctID 
					
					-- Deposit half of the AdClicks.BidRate into the Corporate Account
					UPDATE CorporateAccounts 
						SET Balance = (@CorporateAcctBalance + @ClickRate) 
						WHERE CorporateAcctID = @CorporateAcctID 
						
					-- Record Ad Click
					INSERT INTO [dbo].[AdClicks] (AdID, IPAddress, BidRate, AdvertiserAcctID) 
						VALUES (@AdID, @IPAddress, @ClickRate, @AdvertiserAcctID)
				END
			
			ELSE 		
				BEGIN 
					UPDATE Advertisements SET IsFunded = 0 WHERE AdID = @AdID 
				END 
		END -- 02
END -- 01