unit DashboardPresentation.Dm;

interface

uses
  xFile,
  T_xFile,
  xFile.ChildDataM,
  DPrask,
  NumField,
  GlobPr,
  Model.Attributes,
  System.SysUtils,
  Model.Commands.Attributes,
  UniForm.ViewExecutor,
  Presenter.Interfaces,
  Dx_Pozn,
  UniForm.Commands,
  Model.ViewParams,
  Model.Interfaces,
  Presenter.ObjectAdapters;

{$REGION 'TDashboardPresentationItemDM - Definition'}


type
  TDashboardPresentationItemDM = class(TChildDataM)
  strict private
  private
    procedure OpenRecord;
    function GetRecordId(): string;
    function GetRecordCaptionFromDataModule(): string;

  protected
    procedure InternalDefineLinks; override;
    procedure InternalInitProperties; override;
    function GetImplicitniSloupce: WideString; override;
    procedure InternalDefineFields; override;
    function  LoadRecord(ADataM : TDataM): TDataM;
    
    
  public
    class function GetDMProperty(DMProperty: TDMProperty; aNumber: Integer = 0) : Integer; override;
    class function GetDMString(DMStrProp1: TDMStringProp; DMStrProp2: Integer) : WideString; override;
    
  published

    [Command (cmdAttachedDocumentDashboardItem, '')]
    procedure AttachedDocument_Execute(aAction: IDataActionExecute);

    [Command(cmdLoadViewDashboard, '')]
    procedure LoadViewDashboard_Execute(aAction: IDataActionExecute);

    [FieldDescription('RecordIdFromDataModule')]
    [ParameterField]
    Property RecordIdFromDataModule : String read GetRecordId;

    [FieldDescription('RecordCaptionFromDataModule')]
    [ParameterField]
    Property RecordCaptionFromDataModule : String read GetRecordCaptionFromDataModule;
   
  end;

{$ENDREGION}

{$REGION 'TDashboardPresentationDM - Definition'}

type
  TDashboardPresentationDM = class(TCustomListDataM)
  strict private
    function GetPKName : string;
    function GetUrl : string;
    function GetDashboardPresentationItem: TDashboardPresentationItemDM;
  private

  protected
    procedure InternalDefineFields; override;
    /// <summary>
    /// Sets implicit columns on DM list
    /// </summary>
    function GetImplicitniSloupce: WideString; override;
    /// <summary>
    /// Defines DM relations
    /// </summary>
    procedure InternalDefineChildFields(AChildFile: TxFile); override;
    procedure InternalInitProperties; override;

  public
    constructor Create(xFile, xFileF: TxFile; Vsechny: Boolean); override;
    // procedure NaplnCalcul(C_Pole: Integer; ncType: TncType); override;
    class function GetDMProperty(DMProperty: TDMProperty; aNumber: Integer = 0) : Integer; override;
    class function GetDMString(DMStrProp1: TDMStringProp; DMStrProp2: Integer) : WideString; override;

  published

   [ParameterField]
   [FieldDescription('DashboardPK')]
   property PKDashboard: String read GetPKName;

   [ParameterField]
   [FieldDescription('Url')]
   property Url: String read GetUrl;

   [Command(cmdStartDashboardPresentation, '')]
   procedure StartPresentation_Execute(aAction: IDataActionExecute);

end;

{$ENDREGION}

implementation

uses
  W_DMList,
  Dicti,
  System.Classes,
  PravaDef,
  Localization,
  AdoFile,
  System.DateUtils,
  Uniform.Manager,
  xConditions,
  smart.Types,
  ColumnCaptionSources.Localization,
  GlobPr.BM,
  DashboardPresentation,
  DashboardPresentationItem,
  SystemSources.Localization,
  RegistraceVazeb,
  Uniform.Types;

{$REGION 'TDashboardPresentationDM - Implementaion'}

function TDashboardPresentationDM.GetPKName: String;
begin
   Result :=  Trim(Self.PK.AsUI);
end;

function TDashboardPresentationDM.GetUrl: String;
var
  LUrl : string;

begin
  LUrl := '?classname=TDashboardPresentationDM&Frgtid=TDashboardPresentationDM_auto&UseMainLayout=0&K2pk=';
  Result :=Trim(Format(LUrl+'%s', [self.GetPKName]));
end;

class function TDashboardPresentationDM.GetDMProperty(DMProperty: TDMProperty; aNumber: Integer = 0): Integer;
begin
  case DMProperty of
    dmpMainXFile:
      Result := E_DashboardPresentation; // Main DM fields
    dmpAS3Supported:
      Result := Ord(as3ReadWrite); // Support of web service
    dmpDataMNo:
      Result := cD_DashboardPresentation; // Identification number of DM
  else
    Result := inherited GetDMProperty(DMProperty, aNumber);
  end;
end;

class function TDashboardPresentationDM.GetDMString(DMStrProp1: TDMStringProp; DMStrProp2: Integer): WideString;
begin
  case DMStrProp1 of
    dmspName:
      Result := LocalizeID(trDashboardPresentationId);// Localized name of DM
    dmspAS3Module:
      Result := AS3ModuleSale; // Category on web service
    dmspAdmin:
      Result := DanielChlopcik; // Author of DM
  else
    Result := inherited GetDMString(DMStrProp1, DMStrProp2);
  end;
end;

function TDashboardPresentationDM.GetImplicitniSloupce: WideString;
begin
  Result := inherited + '[SelectionImgCalc:][RID:][Name:][Description:]';
end;

function TDashboardPresentationDM.GetDashboardPresentationItem
  : TDashboardPresentationItemDM;
var
  LDataField: TDataField;
begin
  if not HaveDataField(DASPRE_ItemChild, LDataField) then
    Exit(nil);
  Result := LDataField.AsDataM as TDashboardPresentationItemDM;
end;

procedure TDashboardPresentationDM.InternalDefineFields;
begin
  inherited;
end;

procedure TDashboardPresentationDM.InternalDefineChildFields(AChildFile: TxFile);
begin
  inherited;
  TChildField.Add(self, AChildFile, DASPRE_ItemChild, 'ItemChild')
    .SetChildDataMNo(cD_DashboardPresentationItem).SetDataControllerActions([dcaShow, dcaCopy, dcaEdit, dcaInsert, dcaDelete, dcaPut])
    .SetChildControllerStyle(ccsDependent, True)
    .SetChildItemNo((DPI_SequenceNumber), insMoveable)
    .AddJoinFieldToField(DP_RID, DPI_MasterRID, True).ExposeToScript
    .OrderBy.Add.Init([(DPI_SequenceNumber)]);
end;

procedure TDashboardPresentationDM.StartPresentation_Execute(aAction: IDataActionExecute);
var
  lVE: TViewExecutor;
begin
  lVE := TUniFormManager.CreateViewExecutor(nil);
  try
    lVE.Instance:= Self;
    lVE.OwnedInstance := False;
    lVE.VCX.Placement.MaximizeAll := True;
    lVE.FragmentId := 'TDashboardPresentationDM_Auto';
    LVE.Show;
  finally
    FreeAndNil(lVE);
  end;
end;

procedure TDashboardPresentationDM.InternalInitProperties;
begin
  FieldNumberDocumentNumber := RIDFieldNumber;
  inherited;
  FieldNumberLockId := DP_RID; // Field for database holding
  FieldNumberInvalidation := DP_IsInvalidRecord;
  DPZ := DP_ChangedOn; // Field of last change
  DPZKdo := DP_ChangedById; // Field of last change author
  DV := DP_CreatedOn; // Field of creation date
  DVKdo := DP_CreatedById; // Field of author

  RightIdBrowse   := rP_DashboardPresentation; //Right for document viewing
  RightIdEdit     := rZ_DashboardPresentation; //Right for document changing
  RightIdNew      := rN_DashboardPresentation; //Right for document creation

end;

constructor TDashboardPresentationDM.Create(xFile, xFileF: TxFile; Vsechny: Boolean);
begin
  RIDFieldNumber := DP_RID;
  inherited;
end;

{$ENDREGION}

{$REGION 'TDashboardPresentationItemDM - Implementation'}

function TDashboardPresentationItemDM.GetRecordCaptionFromDataModule(): string;
begin
  Result := DataField[(DPI_Description)].AsString;
end;

 
function TDashboardPresentationItemDM.GetRecordId(): string;
begin
  Result := DataField[(DPI_RecordPK)].AsString;
end;

procedure TDashboardPresentationItemDM.InternalDefineFields;
begin
  inherited;

  DataField[DPI_RID].Enabled := False;
  DataField[DPI_MasterRID].Enabled := False;
  DataField[DPI_Name].Required := True;
  DataField[DPI_DisplayTime].Required := True;
end;


procedure TDashboardPresentationItemDM.InternalDefineLinks;

begin
  inherited;
  BindRegistration.ZavolejVazbu(tbDM, DataField[(DPI_DataModule)], [faNoRequired]);
  DataField[DPI_DataModule].Vazba.OnAdaptLookupFilter := procedure(AFilter: TMemorySetFilter)
    begin
      (AFilter as TxFilter).Conditions.AddField.Init([DMCLDM_PrimaryKeySegmentCount], foEqual, 1);
    end;

  AddDynamicLink(cD_ScriptAndReport, DataField[DPI_ScriptID], False);
end;

procedure TDashboardPresentationItemDM.AttachedDocument_Execute(aAction: IDataActionExecute);
begin
  OpenRecord;
end;

function  TDashboardPresentationItemDM.LoadRecord(ADataM : TDataM): TDataM;
var
  LTempDataM : TDataM;
begin
  LTempDataM := ADataM;
  if (not DataField[(DPI_RecordPK)].IsEmpty) then
  begin
    if (not Assigned(LTempDataM.DataFieldRID)) then
      LTempDataM.DoGetKeyBySingleSegmentPK(DataField[(DPI_RecordPK)].AsVariant)
    else
      LTempDataM.DoGetKeyByRID(StrToInt64(Trim(DataField[(DPI_RecordPK)].AsString)));
  end;

  Result := LTempDataM;
end;

procedure TDashboardPresentationItemDM.OpenRecord;
var
  LDataM: TDataM;
begin
  if DataField[(DPI_DataModule)].IsEmpty then Exit;
  LDataM := Dict.GetDuplDataModule(DataField[DPI_DataModule].AsInt64);
  try
    if Assigned(LDataM) then begin
      LDataM := LoadRecord(LDataM);
    end;
    
    if TUniFormManager.DialogExecutor.ShowLookupModal(LDataM, '') and IsEditMode then
    begin
      DataField[(DPI_RecordPK)].AsControlValue := LDataM.MasterLinkSegment(LDataM.Novy, dpCis);
      LDataM := LoadRecord(LDataM);
      DataField[(DPI_Description)].AsControlValue := Trim(LDataM.RecordCaption);
      DataField[(DPI_Name)].AsControlValue := Trim(LDataM.RecordCaption);
    end;
  finally
    FreeAndNil(LDataM);
  end;
end;

procedure TDashboardPresentationItemDM.LoadViewDashboard_Execute(aAction: IDataActionExecute);
var
  LSelectedView :  TViewParameters;
  LDataM : TDataM;

begin
  if (DataField[DPI_DataModule].IsEmpty = False) then
  begin
    LDataM := Dict.GetDuplDataModule(DataField[DPI_DataModule].AsInt64);
    try
      LSelectedView := TPresenterViewObjectAdapters.ShowObjectLookupModal<TViewParameters>(LDataM.ClassName, LDataM);
      try
        if Assigned(LSelectedView) then
          DataField[DPI_View].AsGUID := LSelectedView.GUID
        ;
      finally
        FreeAndNil(LSelectedView);
      end;
    finally
      FreeAndNil(LDataM);
    end;
  end;
end;

procedure TDashboardPresentationItemDM.InternalInitProperties;
begin
  inherited;
  // Fields
  FieldNumberDocumentNumber := RIDFieldNumber; // ?
  FieldNumberLockId := DPI_RID; // Field for database holding

  RightIdEdit     := rZ_DashboardPresentationItem; //Right for document changing
  RightIdNew      := rZ_DashboardPresentationItem;

end;

function TDashboardPresentationItemDM.GetImplicitniSloupce: WideString;
begin
   Result := inherited + Format('[SelectionImgCalc:][RID:][SequenceNumber:%s][Name:][DisplayTime:%s]', [LocalizeId(trSequenceNumberId), LocalizeId(trDisplayTimeId)]);
end;

class function TDashboardPresentationItemDM.GetDMProperty (DMProperty: TDMProperty; aNumber: Integer = 0): Integer;
begin
  case DMProperty of
    dmpMainXFile:
      Result := E_DashboardPresentationItem; // Main DM fields
    dmpAS3Supported:
      Result := Ord(as3ReadWrite); // Support of web service
  else
    Result := inherited GetDMProperty(DMProperty, aNumber);
  end;
end;

class function TDashboardPresentationItemDM.GetDMString (DMStrProp1: TDMStringProp; DMStrProp2: Integer): WideString;
begin
  case DMStrProp1 of
    dmspAdmin:
      Result := DanielChlopcik;
    dmspName:
      Result := LocalizeID(trDashboardPresentationItemId);
  else
    Result := inherited GetDMString(DMStrProp1, DMStrProp2);
  end;
end;

{$ENDREGION}

initialization

  TDictionary.RegisterChildDataM(TDashboardPresentationItemDM, cD_DashboardPresentationItem);

  TDMList.AddDataM(TDashboardPresentationDM, cD_DashboardPresentation, []);
  TDictionary.AddDataModule(TDashboardPresentationDM);
  System.Classes.RegisterClass(TDashboardPresentationDM);

end.
