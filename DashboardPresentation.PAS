unit DashboardPresentation;

interface

uses
  Fields;

const
  E_DashboardPresentation = 1484;

  DP_RID       = $5CC0001; DP_Description = $5CC0002; DP_CreatedById     = $5CC0003;
  DP_CreatedOn = $5CC0004; DP_ChangedOn   = $5CC0005; DP_ChangedById     = $5CC0006;
  DP_TimeStamp = $5CC0007; DP_Name        = $5CC0008; DP_IsInvalidRecord = $5CC0009;

  DP_ByRID = 0;


implementation

uses
  Dicti, GlobPr;

const
  FieldCount   = 9;
  WidthCount   = 2;
  DecimCount   = 0;
  KeyCount     = 1;
  SegmentCount = 1;
  ZNullCount   = 1;

  Fields: array [0..FieldCount - 1] of TDictField = (
    (S: 'RID'            ; N: 'Èíslo'         ; P: ''    ; T: ftBigInt          ; E: Word(DP_RID            )),
    (S: 'Description'    ; N: 'Popis'         ; P: 'S128'; T: ftWideString {128}; E: Word(DP_Description    )),
    (S: 'CreatedById'    ; N: 'Vytvoøil'      ; P: ''    ; T: ftLong            ; E: Word(DP_CreatedById    )),
    (S: 'CreatedOn'      ; N: 'Vytvoøeno'     ; P: ''    ; T: ftDateTime        ; E: Word(DP_CreatedOn      )),
    (S: 'ChangedOn'      ; N: 'Zmìnìno'       ; P: ''    ; T: ftDateTime        ; E: Word(DP_ChangedOn      )),
    (S: 'ChangedById'    ; N: 'Zmìnil'        ; P: ''    ; T: ftLong            ; E: Word(DP_ChangedById    )),
    (S: 'TimeStamp'      ; N: 'Èasové razítko'; P: ''    ; T: ftTimeStamp       ; E: Word(DP_TimeStamp      )),
    (S: 'Name'           ; N: 'Název'         ; P: 'S64' ; T: ftWideString {64} ; E: Word(DP_Name           )),
    (S: 'IsInvalidRecord'; N: 'Zneplatnìno'   ; P: ''    ; T: ftBool            ; E: Word(DP_IsInvalidRecord)));
  Widths: array [0..WidthCount - 1] of Word = (256, 128);
  Keys: array [0..KeyCount - 1] of TDictKey = (
    (N: 'ByRID'; O: [ixUnique, ixPrimary]; C: 0));
  Segments: array [0..SegmentCount - 1] of TDictSegment = (
    (S: 0; F: Word(DP_RID)));
  ZNulls: array [0..ZNullCount - 1] of Word = (
     Word(DP_TimeStamp));
  FileInfo: TDictFile = (E: E_DashboardPresentation; T: tfAdo; P: pfData; MD: False; N: 'DASHBOARDPRESENTATION'; Desc: 'DashboardPresentation'; Prefix: 'DP';
    OP: nil; F: @Fields; W: @Widths; D: nil; K: @Keys; S: @Segments; Z: @ZNulls;
    FC: FieldCount; WC: WidthCount; DC: DecimCount; KC: KeyCount; SC: SegmentCount; ZC: ZNullCount);

initialization

  TDictionary.AddFileModule(E_DashboardPresentation, FileInfo);

end.
