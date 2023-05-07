unit DashboardPresentationItem;

interface

uses
  Fields;

const
  E_DashboardPresentationItem = 1485;

  DPI_RID        = $5CD0001; DPI_Description    = $5CD0002; DPI_Name        = $5CD0003;
  DPI_MasterRID  = $5CD0004; DPI_DashboardRID   = $5CD0005; DPI_DisplayTime = $5CD0006;
  DPI_DataModule = $5CD0007; DPI_URLAddress     = $5CD0008; DPI_RecordPK    = $5CD0009;
  DPI_Fragment   = $5CD000A; DPI_Zoom           = $5CD000B; DPI_View        = $5CD000C;
  DPI_ScriptID   = $5CD000D; DPI_SequenceNumber = $5CD000E;

  DPI_ByRID          = 0;
  DPI_ByMasterRID    = 1;
  DPI_ByDashboardRID = 2;


implementation

uses
  Dicti, GlobPr;

const
  FieldCount   = 14;
  WidthCount   = 5;
  DecimCount   = 0;
  KeyCount     = 3;
  SegmentCount = 3;
  ZNullCount   = 0;

  Fields: array [0..FieldCount - 1] of TDictField = (
    (S: 'RID'           ; N: '»Ìslo'       ; P: ''    ; T: ftBigInt           ; E: Word(DPI_RID           )),
    (S: 'Description'   ; N: 'Popis'       ; P: 'S128'; T: ftWideString {128} ; E: Word(DPI_Description   )),
    (S: 'Name'          ; N: 'N·zev'       ; P: 'S64' ; T: ftWideString {64}  ; E: Word(DPI_Name          )),
    (S: 'MasterRID'     ; N: 'MasterRID'   ; P: ''    ; T: ftBigInt           ; E: Word(DPI_MasterRID     )),
    (S: 'DashboardRID'  ; N: 'DashboardRID'; P: ''    ; T: ftBigInt           ; E: Word(DPI_DashboardRID  )),
    (S: 'DisplayTime'   ; N: 'DisplayTime' ; P: ''    ; T: ftLong             ; E: Word(DPI_DisplayTime   )),
    (S: 'DataModule'    ; N: 'DataModule'  ; P: ''    ; T: ftBigInt           ; E: Word(DPI_DataModule    )),
    (S: 'URLAddress'    ; N: 'URLAddress'  ; P: ''    ; T: ftWideString {2000}; E: Word(DPI_URLAddress    )),
    (S: 'RecordPK'      ; N: 'RecordPK'    ; P: ''    ; T: ftWideString {1000}; E: Word(DPI_RecordPK      )),
    (S: 'Fragment'      ; N: 'Fragment'    ; P: ''    ; T: ftWideString {1000}; E: Word(DPI_Fragment      )),
    (S: 'Zoom'          ; N: 'Zoom'        ; P: ''    ; T: ftReal             ; E: Word(DPI_Zoom          )),
    (S: 'View'          ; N: 'View'        ; P: ''    ; T: ftGUID             ; E: Word(DPI_View          )),
    (S: 'ScriptID'      ; N: 'ScriptID'    ; P: ''    ; T: ftBigInt           ; E: Word(DPI_ScriptID      )),
    (S: 'SequenceNumber'; N: 'Order'       ; P: ''    ; T: ftLong             ; E: Word(DPI_SequenceNumber)));
  Widths: array [0..WidthCount - 1] of Word = (256, 128, 4000, 2000, 2000);
  Keys: array [0..KeyCount - 1] of TDictKey = (
    (N: 'ByRID';          O: [ixUnique, ixPrimary]; C: 0),
    (N: 'ByMasterRID';    O: [                   ]; C: 0),
    (N: 'ByDashboardRID'; O: [                   ]; C: 0));
  Segments: array [0..SegmentCount - 1] of TDictSegment = (
    (S: 0; F: Word(DPI_RID         )),
    (S: 0; F: Word(DPI_MasterRID   )),
    (S: 0; F: Word(DPI_DashboardRID)));
  FileInfo: TDictFile = (E: E_DashboardPresentationItem; T: tfAdo; P: pfData; MD: False; N: 'DASHBOARDPRESENTATIONITEM'; Desc: 'DashboardPresentationItem'; Prefix: 'DPI';
    OP: nil; F: @Fields; W: @Widths; D: nil; K: @Keys; S: @Segments; Z: nil;
    FC: FieldCount; WC: WidthCount; DC: DecimCount; KC: KeyCount; SC: SegmentCount; ZC: ZNullCount);

initialization

  TDictionary.AddFileModule(E_DashboardPresentationItem, FileInfo);

end.
