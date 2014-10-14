SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Robert Vignato
-- Create date: 8/22/2012
-- Description:	Update Advertiser Account Balance
-- =============================================
ALTER PROCEDURE [dbo].[sp_UPDATE_IncreaseBalance] -- v01
	-- Add the parameters for the stored procedure here
	@FullAmount MONEY 
	, @CPAcctID INT 
	--, @TransactionType NVARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @CorporateAcctID INT 
	SET @CorporateAcctID = 4 
	DECLARE @HalfAmount MONEY 
	SET @HalfAmount = (@FullAmount / 2)
	-------------------------------------------
	DECLARE @CurrentBalance_ContentProviderAccount MONEY 
	SET @CurrentBalance_ContentProviderAccount = (SELECT Balance FROM ContentProviderAccounts WHERE CPAcctID = @CPAcctID)  
	-------------------------------------------
    -- Insert statements for procedure here
	UPDATE ContentProviderAccounts 
	SET Balance = (@CurrentBalance_ContentProviderAccount + @HalfAmount) 
	WHERE (CPAcctID = @CPAcctID)   
	-------------------------------------------
	DECLARE @CurrentBalance_CorporateAccount MONEY 
	SET @CurrentBalance_CorporateAccount = (SELECT Balance FROM CorporateAccounts WHERE CorporateAcctID = @CorporateAcctID)
	-------------------------------------------
	UPDATE CorporateAccounts  
	SET Balance = (@CurrentBalance_CorporateAccount + @HalfAmount) 
	WHERE (CorporateAcctID = @CorporateAcctID) 
	-------------------------------------------
END
GO
