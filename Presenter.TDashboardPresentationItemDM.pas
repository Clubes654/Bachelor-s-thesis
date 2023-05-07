unit Presenter.TDashboardPresentationItemDM;

interface

implementation

uses
  System.SysUtils,
  GlobPr,
  UniForm.GlobVar,
  T_xFile,
  Ca_Xml,
  xfile,
  numfield,
  Dicti,
  Model.Commands.Attributes,
  Model.Attributes,
  UniForm.Commands,
  DashboardPresentation.Dm,
  Presenter.TChildDataM,
  DashboardPresentationItem,
  UniForm.Manager,
  UniForm.ViewExecutor,
  UniForm.Types,
  ARDashboard,
  Model.Utils,
  Presenter.Interfaces;

type
  TPresenterViewTDDashboardPresentationItem = class(TPresenterViewTChildDataM<TDashboardPresentationItemDM>)
  strict private
   // fCounterTime: int64;
    fNotViewForm : boolean;
    fIsSort : boolean;
  private

    function GetAbbrName: String;
    function GetAbbrDashboard(const ADashboardID: int64): String;
    function ShowUniForm(aDataM : TDataM; aTime : integer): boolean;
    function GetRecordAndShowUniform(aTime : integer) : boolean;
    procedure OpenDashboradRecord;
  public

  published

    [Command(cmdLoadNextDashboardItem, '')]
    [CommandInit('LoadNextDashboardItem_Init')]
    procedure LoadNextDashboardItem_ExecuteDM(aAction: IDataActionExecute);
    function  LoadNextDashboardItem_Init(aAction: IDataActionInit): Boolean;

    [FieldDescription('AbbrDashboard')]
    property AbbrDashboard: String read GetAbbrName; // write FAbbrName;

    [Command(cmdAddItemDashboard, 'AddItemDashboard_Update')]
    procedure AddItemDashboard_Execute(aAction: IDataActionExecute);
    procedure AddItemDashboard_Update(aAction: IDataActionUpdate);

  end;

procedure TPresenterViewTDDashboardPresentationItem.LoadNextDashboardItem_ExecuteDM(aAction: IDataActionExecute);
var
  lBookmark: TRowBookmark;
  LListPresenter: IPresenterList;
  LCurrentDisplayTime: Double;
  IsNext : boolean;

begin
  IsNext := False;
  LCurrentDisplayTime := DataM.DataField[DPI_DisplayTime].AsInt64 *1000;
  if Assigned(ListPresenter) then
  begin
    if Assigned(ListPresenter) and
      (Supports(ListPresenter, IPresenterList, LListPresenter)) then
    begin
      lBookmark := CurrentBookmark;

      if (not fNotViewForm) then
      begin
        IsNext := GetRecordAndShowUniform(Trunc(LCurrentDisplayTime));
      end;

      if (IsNext) then
      begin
        LListPresenter.OperateGridCache(gopNext);
        if TModelUtils.RowBookmarkIsSame(lBookmark, CurrentBookmark) then
          LListPresenter.OperateGridCache(gopFirstPage);
          fNotViewForm := False;
      end
      else
      begin
        fNotViewForm := True;
      end;
    end;
  end;
end;

function TPresenterViewTDDashboardPresentationItem.LoadNextDashboardItem_Init(
  aAction: IDataActionInit): Boolean;
var
  lOrderBy: IOrderBy;
  LListPresenter: IPresenterList;

begin
  Result := fIsSort;
  if Assigned(ListPresenter) and (Supports(ListPresenter, IPresenterList, LListPresenter)) and (not fIsSort) then
  begin
    fIsSort := True;
    lOrderBy := LListPresenter.GetImplicitSortBy;
    if Assigned(lOrderBy) then
      LListPresenter.SetSortBy(lOrderBy, True)
      ;
    LListPresenter.OperateGridCache(gopUpdate);
    Result := True;
  end;
end;

function TPresenterViewTDDashboardPresentationItem.GetRecordAndShowUniform(aTime : integer) : boolean;
var
  LDataM : TDataM;
begin
  Result := false;
  if (DataM.DataField[DPI_DataModule].IsEmpty = False) then
  begin
    LDataM := Dict.GetDuplDataModule(DataM.DataField[DPI_DataModule].AsInt64);
    if (not DataM.DataField[(DPI_RecordPK)].IsEmpty) then
    begin
      if (not Assigned(LDataM.DataFieldRID)) then
        LDataM.DoGetKeyBySingleSegmentPK(DataM.DataField[(DPI_RecordPK)].AsVariant)
      else
        LDataM.DoGetKeyByRID(StrToInt64(Trim(DataM.DataField[(DPI_RecordPK)].AsString)));
    end;
    Result := ShowUniForm(LDataM, aTime);
  end else
  begin
    if not (DataM.DataField[DPI_URLAddress].IsEmpty) then
    begin
      Result := ShowUniForm(DataM, aTime);
    end;
  end;

end;

function TPresenterViewTDDashboardPresentationItem.ShowUniForm(aDataM : TDataM; aTime : integer): boolean;
var
  lVE: TViewExecutor;
  lDataM : TDataM;
  NULLGuid : TGUID;
  LViewResult : TUFViewResult;
begin
  if Assigned(aDataM) then
    lDataM := aDataM
  else
    raise Exception.Create('DM is nil');


  NULLGuid :=  StringToGUID('{00000000-0000-0000-0000-000000000000}');
  lVE := TUniFormManager.CreateViewExecutor(nil);
  try
    lVE.Instance:= lDataM;
    lVE.OwnedInstance := (DataM <> aDataM);
    lVE.FragmentId := Trim(DataM.DataField[DPI_Fragment].AsString);

    if DataM.DataField[DPI_Zoom].AsFloat > 0 then
      lVE.VCX.Zoom := DataM.DataField[DPI_Zoom].AsFloat / 100;

    if not IsEqualGUID(DataM.DataField[DPI_View].AsGUID, NULLGuid) then
      lVE.ViewParametersGUID := DataM.DataField[DPI_View].AsGUID;

    if (DataM.DataField[(DPI_RecordPK)].IsEmpty) then
      lVE.ViewMode := vwmNormal
    else
      lVE.ViewMode := vwmDetail;

    lVE.VCX.Placement.MaximizeAll := True;
    lVE.CloseWithoutQuestion := true;
    lVE.AutoCloseTime := aTime;
    LVE.RectInDock.FrameStyle := frsNone;
    LViewResult := lVE.ShowInModalForm(False);

  finally
    FreeAndNil(lVE);
  end;
  if (LViewResult = ufvrUnknown) then
    Result := True
  else
    Result := False
end;

procedure TPresenterViewTDDashboardPresentationItem.AddItemDashboard_Execute(aAction: IDataActionExecute);
var
  lVE: TViewExecutor;
  lBookmark: TRowBookmark;
  LListPresenter: IPresenterList;

begin
   lVE := TUniFormManager.CreateViewExecutor(nil);
  try
    LVE.Instance := DataM;
    LVE.EditMode := remAppend;
    LVE.ViewMode := vwmNormal;
    LVE.FragmentId := 'TDashboardPresentationDM.TDashboardPresentationItemDM';     

     LVE.DoInitData:=
     procedure (aViewPresenter: IPresenterView; aData: TObject)
     begin
       DataM.DataField[DPI_DataModule].AsInt64 := cD_Dashboard;
       DataM.DataField[DPI_Fragment].AsString := 'TDashboardDM_View';
       OpenDashboradRecord;
     end;

     LVE.RealizerClosed :=
       procedure (aResult: IViewRealizerResult)
       begin
         if aResult.ViewResult = ufvrOK then
         begin
           if Assigned(ListPresenter) then
           begin
             lBookmark := CurrentBookmark;
             if Assigned(ListPresenter) and (Supports(ListPresenter, IPresenterList, LListPresenter)) then
             begin
                LListPresenter.OperateGridCache(gopLastPage);
                LListPresenter.OperateGridCache(gopNext);
             end;
            end;
          end;
        end;


    lVE.Show;
  finally
    FreeAndNil(lVE);
  end;
end;

procedure TPresenterViewTDDashboardPresentationItem.AddItemDashboard_Update(aAction: IDataActionUpdate);
begin
  aAction.Enabled := DataM.DMOwner.IsEditMode;
end;

procedure TPresenterViewTDDashboardPresentationItem.OpenDashboradRecord;
var
  LDataM: TDataM;
begin
  LDataM := Dict.GetDuplDataModule(cD_Dashboard);
  try
    if TUniFormManager.DialogExecutor.ShowLookupModal(LDataM, '') and DataM.IsEditMode then
    begin
      DataM.DataField[(DPI_RecordPK)].AsControlValue := LDataM.MasterLinkSegment(LDataM.Novy, dpCis);
      LDataM.DoGetKeyByRID(StrToInt64(Trim(DataM.DataField[(DPI_RecordPK)].AsString)));
      DataM.DataField[(DPI_Description)].AsControlValue := Trim(LDataM.RecordCaption);
      DataM.DataField[(DPI_Name)].AsControlValue := Trim(LDataM.RecordCaption);
    end;
  finally
    FreeAndNil(LDataM);
  end;
end;

function TPresenterViewTDDashboardPresentationItem.GetAbbrDashboard(const ADashboardID: int64): String;
var
  LDataM: TDataM;

begin
  LDataM := Dict.GetDuplDataModule(cD_Dashboard);
  try
    LDataM.CurrentIndex := ARDB_ByRID;
    LDataM[ARDB_RID].AsInt64 := ADashboardID;
    if LDataM.DoGetKey then
    begin
      Result := Trim(LDataM[ARDB_Abbr].AsString);
    end;
  finally
    FreeAndNil(LDataM);
  end;
end;

function TPresenterViewTDDashboardPresentationItem.GetAbbrName: String;
begin
  Result := GetAbbrDashboard(DataM.DataField[DPI_DashboardRID].AsInt64);
end;

initialization

 TPresenterViewTDDashboardPresentationItem.RegisterPresenter(TDashboardPresentationItemDM, prprDataPriority);

end.
