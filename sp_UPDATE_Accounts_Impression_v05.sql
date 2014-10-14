SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Robert Vignato
-- Create date: 8/22/2012
-- Updated: 11/12/2012
-- Description:	Update Account Balance
-- =============================================
ALTER PROCEDURE [dbo].[sp_UPDATE_Accounts_Impression] -- v05
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
	
	
	DECLARE @AdName NVARCHAR(100)
	SET @AdName = (SELECT AdName FROM Advertisements WHERE (AdID = @AdID))	
	
	
	DECLARE @VideoTitle NVARCHAR(100)
	SET @VideoTitle = (SELECT Title FROM Videos WHERE (VideoID = @VideoID))
	
	
	----------------------------------------------------------------------------------------------
	-------------------------- Advertiser Account ------------------------------------------------
	DECLARE @AdvertiserAcctID INT 	
	SET @AdvertiserAcctID = (SELECT AdvertiserAcctID FROM Advertisements WHERE (AdID = @AdID))
	
	DECLARE @AdvertiserAcctBalance MONEY 
	SET @AdvertiserAcctBalance = (SELECT AdvertiserAccounts.Balance 
									FROM AdvertiserAccounts 
									INNER JOIN Advertisements ON AdvertiserAccounts.AdvertiserAcctID = Advertisements.AdvertiserAcctID 
									WHERE (Advertisements.AdID = @AdID))
									
	DECLARE @AdvUserId UNIQUEIDENTIFIER ---------------------------- v05
	SET @AdvUserId = (SELECT TOP (1) AdvertiserAccounts.AdvertiserAcctID, AdvertiserAccounts.UserId
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

	DECLARE @CPUserId UNIQUEIDENTIFIER ---------------------------- v05
	SET @CPUserId = (SELECT TOP (1) ContentProviderAccounts.UserId
							FROM ContentProviderAccounts 
							INNER JOIN Videos ON ContentProviderAccounts.CPAcctID = Videos.CPAcctID
							WHERE (Videos.VideoID = @VideoID))


	-------------------------- Corporate Account -------------------------------------------------
	DECLARE @CorporateAcctID INT 	
	SET @CorporateAcctID = 4 
	
	DECLARE @CorporateAcctBalance MONEY 
	SET @CorporateAcctBalance = (SELECT Balance FROM CorporateAccounts WHERE CorporateAcctID = @CorporateAcctID)
	
	DECLARE @CorporateUserId UNIQUEIDENTIFIER ---------------------------- v05
	SET @CorporateUserId = (SELECT TOP (1) UserId FROM CorporateAccounts WHERE CorporateAcctID = @CorporateAcctID)

	
	----------------------------------------------------------------------------------------------
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
					DECLARE @AdjustedAdvertiserAcctBalance MONEY ------------------------------- v05	
					SET @AdjustedAdvertiserAcctBalance = (@AdvertiserAcctBalance - @ImpressionRate) ------------------------------- v05	
					UPDATE AdvertiserAccounts 
						SET Balance = @AdjustedAdvertiserAcctBalance
						, LastBilled_AdID = @AdID ---------------------------------------------- v02
						, LastBilled_AdName = @AdName ------------------------------------------------- v03
						, LastBilled_BbID = NULL ----------------------------------------------- v02
						, LastBilled_BbTypeID = NULL ------------------------------------------- v02
						, LastBilled_BbType = NULL --------------------------------------------- v02
						, LastBilled_VideoID = @VideoID ---------------------------------------- v02
						, LastBilled_VideoTitle = @VideoTitle ----------------------------------------- v03
						, LastTransaction_Type = 'Impression' ------------------------------------------------ v04 
						WHERE AdvertiserAcctID = @AdvertiserAcctID 
					
					-- Add History to AdvertiserAccounts_History ------------------------------------ v05
					INSERT INTO AdvertiserAccounts_History (
						AdvertiserAcctID
						, UserId
						, CreatedOn
						, Balance 
						, IsActive
						, IsVisible
						, IsLocked
						, IsFunded	
						, IPAddress
						, LastBilled_AdID
						, LastBilled_AdName
						, LastBilled_BbID
						, LastBilled_BbTypeID
						, LastBilled_BbType
						, LastBilled_VideoID
						, LastBilled_VideoTitle 
						, LastTransaction_Type 
						, History_CreatedOn
						, History_CreatedByUserName
						, History_Action
						)		
					VALUES (
						@AdvertiserAcctID
						, @AdvUserId
						, GETDATE()
						, @AdjustedAdvertiserAcctBalance
						, 1 -- IsActive 
						, 1 -- IsVisible 
						, 0 -- IsLocked 
						, 1 -- IsFunded	- Tested above - IF @AdvertiserAcctBalance >= @ImpressionRate + @ImpressionRate 
						, @IPAddress
						, @AdID -- LastBilled_AdID
						, @AdName -- LastBilled_AdName
						, NULL -- LastBilled_BbID
						, NULL -- LastBilled_BbTypeID
						, NULL -- LastBilled_BbType
						, @VideoID -- LastBilled_VideoID
						, @VideoTitle -- LastBilled_VideoTitle
						, 'Impression' -- LastTransaction_Type 
						, GETDATE()
						, SUSER_SNAME()
						, 'TxnHx')

					------------------------------------------------------------------------------------------------------------------------	
					
					-- Deposit half of the AdImpressions.BidRate into the Content Providers Account
					DECLARE @AdjustedCPAcctBalance MONEY ------------------------------- v05	
					SET @AdjustedCPAcctBalance = (@CPAcctBalance + (@ImpressionRate / 2)) ------------------------------- v05	
					UPDATE ContentProviderAccounts 
						SET Balance = @AdjustedCPAcctBalance ------------------------------- v05	
						, LastBilled_AdID = @AdID ---------------------------------------------- v02
						, LastBilled_AdName = @AdName ------------------------------------------------- v03
						, LastBilled_BbID = NULL ----------------------------------------------- v02
						, LastBilled_BbTypeID = NULL ------------------------------------------- v02
						, LastBilled_BbType = NULL --------------------------------------------- v02
						, LastBilled_VideoID = @VideoID ---------------------------------------- v02
						, LastBilled_VideoTitle = @VideoTitle ----------------------------------------- v03
						, LastTransaction_Type = 'Impression' ------------------------------------------------ v04 
						WHERE CPAcctID = @CPAcctID 
						
					-- Add History to ContentProviderAccounts_History ------------------------------- v05
					INSERT INTO ContentProviderAccounts_History (
						CPAcctID
						, UserId
						, CreatedOn
						, Balance 
						, IsActive
						, IsVisible
						, IsLocked
						, IsFunded	
						, IPAddress
						, LastBilled_AdID
						, LastBilled_AdName
						, LastBilled_BbID
						, LastBilled_BbTypeID
						, LastBilled_BbType
						, LastBilled_VideoID
						, LastBilled_VideoTitle 
						, LastTransaction_Type 
						, History_CreatedOn
						, History_CreatedByUserName
						, History_Action
						)		
					VALUES (
						@CPAcctID
						, @CPUserId
						, GETDATE()
						, @AdjustedCPAcctBalance
						, 1 -- IsActive 
						, 1 -- IsVisible 
						, 0 -- IsLocked 
						, 1 -- IsFunded	- Tested above - IF @AdvertiserAcctBalance >= @ImpressionRate + @ImpressionRate 
						, @IPAddress
						, @AdID -- LastBilled_AdID
						, @AdName -- LastBilled_AdName
						, NULL -- LastBilled_BbID
						, NULL -- LastBilled_BbTypeID
						, NULL -- LastBilled_BbType
						, @VideoID -- LastBilled_VideoID
						, @VideoTitle -- LastBilled_VideoTitle
						, 'Impression' -- LastTransaction_Type 
						, GETDATE()
						, SUSER_SNAME()
						, 'TxnHx')
						
					------------------------------------------------------------------------------------------------------------------------	
					
					-- Deposit half of the AdImpressions.BidRate into the Corporate Account
					DECLARE @AdjustedCorporateBalance MONEY ------------------------------- v05
					SET @AdjustedCorporateBalance = (@CorporateAcctBalance + (@ImpressionRate / 2)) ------------------------------- v05
					UPDATE CorporateAccounts 
						SET Balance = @AdjustedCorporateBalance ------------------------------- v05
						, LastBilled_AdID = @AdID ---------------------------------------------- v02
						, LastBilled_AdName = @AdName ------------------------------------------------- v03
						, LastBilled_BbID = NULL ----------------------------------------------- v02
						, LastBilled_BbTypeID = NULL ------------------------------------------- v02
						, LastBilled_BbType = NULL --------------------------------------------- v02
						, LastBilled_VideoID = @VideoID ---------------------------------------- v02
						, LastBilled_VideoTitle = @VideoTitle ----------------------------------------- v03
						, LastTransaction_Type = 'Impression' ------------------------------------------------ v04 
						WHERE CorporateAcctID = @CorporateAcctID 
						
					-- Add History to CorporateAccounts_History ------------------------------- v05
					INSERT INTO CorporateAccounts_History (
						CorporateAcctID
						, UserId
						, CreatedOn
						, Balance 
						, IsActive
						, IsVisible
						, IsLocked
						, IsFunded	
						, IPAddress
						, LastBilled_AdID
						, LastBilled_AdName
						, LastBilled_BbID
						, LastBilled_BbTypeID
						, LastBilled_BbType
						, LastBilled_VideoID
						, LastBilled_VideoTitle 
						, LastTransaction_Type 
						, History_CreatedOn
						, History_CreatedByUserName
						, History_Action
						)		
					VALUES (
						@CorporateAcctID
						, @CorporateUserId
						, GETDATE()
						, @AdjustedCorporateBalance
						, 1 -- IsActive 
						, 1 -- IsVisible 
						, 0 -- IsLocked 
						, 1 -- IsFunded	- Tested above - IF @AdvertiserAcctBalance >= @ImpressionRate + @ImpressionRate 
						, @IPAddress
						, @AdID -- LastBilled_AdID
						, @AdName -- LastBilled_AdName
						, NULL -- LastBilled_BbID
						, NULL -- LastBilled_BbTypeID
						, NULL -- LastBilled_BbType
						, @VideoID -- LastBilled_VideoID
						, @VideoTitle -- LastBilled_VideoTitle
						, 'Impression' -- LastTransaction_Type 
						, GETDATE()
						, SUSER_SNAME()
						, 'TxnHx')

				END
			
			ELSE 		
				BEGIN 
					UPDATE Advertisements SET IsFunded = 0 WHERE AdID = @AdID 
				END 
		END -- 02
END -- 01