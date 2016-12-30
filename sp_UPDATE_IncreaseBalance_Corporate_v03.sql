SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Robert Vignato
-- Description:	Update Advertiser Account Balance
-- =============================================
ALTER PROCEDURE [dbo].[sp_UPDATE_IncreaseBalance_Corporate] -- v03
	-- Add the parameters for the stored procedure here
	@FullAmount MONEY 
	, @IPAddress NVARCHAR(16)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @CorporateAcctID INT 
	SET @CorporateAcctID = 4 
	-------------------------------------------
	--DECLARE @HalfAmount MONEY 
	--SET @HalfAmount = (@FullAmount / 2)
	-------------------------------------------
	DECLARE @CurrentBalance_CorporateAccount MONEY 
	SET @CurrentBalance_CorporateAccount = (SELECT Balance FROM CorporateAccounts WHERE CorporateAcctID = @CorporateAcctID)  
	-------------------------------------------	
	DECLARE @MinimumWaitPeriod INT SET @MinimumWaitPeriod = 60  
	DECLARE @ElapsedTimeSinceLastHit INT 
	SET @ElapsedTimeSinceLastHit = (SELECT TOP (2) DATEDIFF(second, MAX(CreatedOn), GETDATE()) 
	FROM AdImpressions 
	WHERE IPAddress = @IPAddress)
	BEGIN -- 02
		IF (@ElapsedTimeSinceLastHit < @MinimumWaitPeriod)
			BEGIN
				PRINT 'No Corporate Provider Account Balance increase'
			END
		ELSE
			BEGIN
				-- OK to increase Balance
				UPDATE CorporateAccounts 
				SET Balance = (@CurrentBalance_CorporateAccount + (@FullAmount / 2)) 
				WHERE (CorporateAcctID = @CorporateAcctID) 
			END
	END -- 02
END -- 01
GO


					---- UPDATE - Deduct Advertisers Account
					--UPDATE AdvertiserAccounts SET Balance = @AdvertiserAcctBalance - @ImpressionRate WHERE AdvertiserAcctID = @AdvertiserAcctID 
					---- UPDATE - Deposit half of the AdImpressions.BidRate into the Content Providers Account
					--UPDATE ContentProviderAccounts SET Balance = (@CPAcctBalance + (@ImpressionRate / 2)) WHERE CPAcctID = @CPAcctID 
					---- UPDATE - Deposit half of the AdImpressions.BidRate into the Corporate Account
					--UPDATE CorporateAccounts SET Balance = (@CorporateAcctBalance + (@ImpressionRate / 2)) WHERE CorporateAcctID = @CorporateAcctID 