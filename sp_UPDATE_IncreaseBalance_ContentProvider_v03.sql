SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Robert Vignato
-- Description:	Update Advertiser Account Balance
-- =============================================
ALTER PROCEDURE [dbo].[sp_UPDATE_IncreaseBalance_ContentProvider] -- v03
	-- Add the parameters for the stored procedure here
	@FullAmount MONEY 
	, @CPAcctID INT 
	, @IPAddress NVARCHAR(16)
AS
BEGIN -- 01
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		
	DECLARE @HalfAmount MONEY 
	SET @HalfAmount = (@FullAmount / 2)
	-------------------------------------------
	DECLARE @CurrentBalance_ContentProviderAccount MONEY 
	SET @CurrentBalance_ContentProviderAccount = (SELECT Balance FROM ContentProviderAccounts WHERE CPAcctID = @CPAcctID)  
	-------------------------------------------	
	DECLARE @MinimumWaitPeriod INT SET @MinimumWaitPeriod = 60  
	DECLARE @ElapsedTimeSinceLastHit INT 
	SET @ElapsedTimeSinceLastHit = (SELECT TOP (2) DATEDIFF(second, MAX(CreatedOn), GETDATE()) 
	FROM AdImpressions 
	WHERE IPAddress = @IPAddress)
	BEGIN -- 02
		IF (@ElapsedTimeSinceLastHit < @MinimumWaitPeriod)
			BEGIN
				PRINT 'No Content Provider Account Balance increase'
			END
		ELSE
			BEGIN
				-- OK to increase Balance
				UPDATE ContentProviderAccounts 
				SET Balance = (@CurrentBalance_ContentProviderAccount + @HalfAmount) 
				WHERE (CPAcctID = @CPAcctID) 
			END
	END -- 02
END -- 01
GO
