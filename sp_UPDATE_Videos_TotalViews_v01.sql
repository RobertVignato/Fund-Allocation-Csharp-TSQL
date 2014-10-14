SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Robert Vignato
-- Create date: 10/03/2012
-- Description:	Update Videos.TotalViews
-- =============================================
ALTER PROCEDURE [dbo].[sp_UPDATE_Videos_TotalViews] -- v01
	@VideoID INT 
	, @TotalViews INT 
AS
BEGIN 
	SET NOCOUNT ON;	
	UPDATE Videos SET TotalViews = @TotalViews, TotalViewsUpdatedOn = GETDATE() WHERE VideoID = @VideoID 	
END
			
