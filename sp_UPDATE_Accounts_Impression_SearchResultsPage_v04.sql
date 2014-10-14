SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Robert Vignato
-- Create date: 8/30/2012
-- Description:	Update Account Balance
-- =============================================
ALTER PROCEDURE [dbo].[sp_UPDATE_Accounts_Impression_SearchResultsPage] -- v04
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
	
	DECLARE @BbType NVARCHAR(50)
	SET @BbType = (SELECT BillboardTypes.Type 
					FROM Billboards 
					INNER JOIN BillboardTypes ON Billboards.BbTypeID = BillboardTypes.BbTypeID 
					WHERE (Billboards.BbID = @BbID))	
	
	DECLARE @AdName NVARCHAR(100)
	SET @AdName = (SELECT AdName FROM Advertisements WHERE (AdID = @AdID))	
	
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
					-- Deduct Advertisers Account
					UPDATE AdvertiserAccounts 
						SET Balance = (@AdvertiserAcctBalance - @ImpressionRate) 
						, LastBilled_AdID = @AdID ---------------------------------------------- v02
						, LastBilled_AdName = @AdName ------------------------------------------------ v03
						, LastBilled_BbID = @BbID ---------------------------------------------- v02
						, LastBilled_BbTypeID = NULL ------------------------------------------------- v03
						, LastBilled_BbType = @BbType ------------------------------------------------ v03
						, LastBilled_VideoID = NULL -------------------------------------------- v02
						, LastBilled_VideoTitle = NULL ----------------------------------------- v02
						, LastTransaction_Type = 'Impression' ------------------------------------------------ v04 
						WHERE AdvertiserAcctID = @AdvertiserAcctID 
					
					-- Deposit ALL of the AdImpressions.BidRate into the Corporate Account
					UPDATE CorporateAccounts 
						SET Balance = (@CorporateAcctBalance + @ImpressionRate) 
						, LastBilled_AdID = @AdID ---------------------------------------------- v02
						, LastBilled_AdName = @AdName ------------------------------------------------ v03
						, LastBilled_BbID = @BbID ---------------------------------------------- v02
						, LastBilled_BbTypeID = NULL ------------------------------------------------- v03
						, LastBilled_BbType = @BbType ------------------------------------------------ v03
						, LastBilled_VideoID = NULL -------------------------------------------- v02
						, LastBilled_VideoTitle = NULL ----------------------------------------- v02
						, LastTransaction_Type = 'Impression' ------------------------------------------------ v04 
						WHERE CorporateAcctID = @CorporateAcctID 
				END
			
			ELSE 		
				BEGIN 
					UPDATE Advertisements SET IsFunded = 0 WHERE AdID = @AdID 
				END 
		END -- 02
END -- 01