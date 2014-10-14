SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Robert Vignato
-- Create date: 8/21/2012
-- Description:	Update Advertiser Account Balance
-- =============================================
ALTER PROCEDURE [dbo].[sp_UPDATE_ReduceBalance_Advertiser] -- v02
	-- Add the parameters for the stored procedure here
	@Amount MONEY 
	, @AdvertiserAcctID INT 
	, @IPAddress NVARCHAR(16)
AS
BEGIN -- 01
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @CurrentBalance MONEY 
	SET @CurrentBalance = (SELECT Balance FROM AdvertiserAccounts WHERE AdvertiserAcctID = @AdvertiserAcctID)
	-------------------------------------------
	DECLARE @MinimumWaitPeriod INT SET @MinimumWaitPeriod = 60  
	DECLARE @ElapsedTimeSinceLastHit INT 
	SET @ElapsedTimeSinceLastHit = (SELECT TOP (2) DATEDIFF(second, MAX(CreatedOn), GETDATE()) 
	FROM AdImpressions 
	WHERE IPAddress = @IPAddress)
	BEGIN -- 02
		IF (@ElapsedTimeSinceLastHit < @MinimumWaitPeriod)
			BEGIN
				PRINT 'No Advertiser Account Balance reduction'
			END
		ELSE
			BEGIN
				-- OK to increase Balance
				UPDATE AdvertiserAccounts 
				SET Balance = (@CurrentBalance - @Amount) 
				WHERE (AdvertiserAcctID = @AdvertiserAcctID) 
			END
	END -- 02
END -- 01
GO
