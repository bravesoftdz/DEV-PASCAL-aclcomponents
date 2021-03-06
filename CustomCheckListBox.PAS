Unit CustomCheckListBox;

Interface

Uses
  Classes,Forms,Graphics,StdCtrls, SysUtils;

Type

  ECheckListException = class( Exception );

  TCheckListBoxData = class
    Data: TObject;
    Checked: boolean;
  end;

  TCustomCheckListBox=Class(TListBox)
  Protected
    FBitmapList: TBitmapList;
    FOnCheckboxChanged: TNotifyEvent;
  Protected
    Function GetChecked( Index: LongInt ): boolean;
    Procedure SetChecked( Index: LongInt; Value:boolean );

    Function GetString( Index: LongInt ): string;
    Procedure SetString( Index: LongInt; Value: string );
    Function GetObject( Index: LongInt ): TObject;
    Procedure SetObject( Index: LongInt; Value: TObject );

    Function GetItemCount: longint;

    Function GetSelectedObject: TObject;
    Procedure SetSelectedObject( Value: TObject );
    Function GetSelectedString: string;
    Function GetCheckedCount: longint;
  Protected
    Procedure SetupComponent; Override;
    Destructor Destroy; Override;
    Procedure MouseClick( Button: TMouseButton;
                          ShiftState: TShiftState;
                          X, Y: longint ); override;
    Procedure MouseDblClick( Button: TMouseButton;
                             ShiftState: TShiftState;
                             X, Y: longint ); override;
    Procedure DrawItem( Index: LongInt;
                        rec: TRect;
                        State: TOwnerDrawState ); Override;
    Procedure CharEvent( Var key: Char;
                         RepeatCount: Byte ); Override;

    Procedure CheckCheckboxHit( X, Y: longint );
    Property Style;
  Public
    property ItemCount: longint read GetItemCount;
    Property Checked[ Index: LongInt ]: boolean Read GetChecked Write SetChecked;
    Property Objects[ Index: longint ]: TObject read GetObject Write SetObject;

    Function AddItemObject( TheString: string;
                            TheObject: TObject;
                            Checked: boolean ): longint;
    Procedure Clear; override;
    Property CheckedCount: longint read GetCheckedCount;

    // get the checked items (and objects) to dest
    Procedure GetCheckedItems( Dest: TStrings );
    // same as above, but don't clear dest beforehand
    Procedure AddCheckedItems( Dest: TStrings );
    Property SelectedObject: TObject read GetSelectedObject write SetSelectedObject;
    Property SelectedString: string read GetSelectedString;

  Published
    Property OnCheckBoxChanged:TNotifyEvent Read FOnCheckboxChanged Write FOnCheckboxChanged;
  End;

Exports
  TCustomCheckListBox, 'User', 'CustomCheckListBox.bmp';

Implementation

Uses
  PMWin, OS2Def;

{$R CustomCheckListBox}

Procedure TCustomCheckListBox.SetupComponent;
Begin
  Inherited SetupComponent;

  Name := 'CustomCheckListBox';
  Style := lbOwnerdrawFixed;
  ItemHeight := 20;
  FBitmapList:= TBitmapList.Create;
  FBitmapList.AddResourceName('BmpLBUnChecked');
  FBitmapList.AddResourceName('BmpLBChecked');
End;


Destructor TCustomCheckListBox.Destroy;
Begin
  Inherited Destroy;
  FBitmapList.Destroy;
End;

Procedure TCustomCheckListBox.DrawItem( Index: LongInt;
                                        rec: TRect;
                                        State: TOwnerDrawState );
var
  textWidth, textHeight: longint;
  destWidth, destHeight: longint;
  textY: Longint;
  s: string;
  Dest: Trect;
  X: longint;
  Bitmap: TBitmap;
  idx: longint;
  Item: TCheckListBoxData;
Begin

  Dest:= rec;
  dec( Dest.top ); // minor adjustments since we seem to get a slightly
  inc( Dest.left ); // incorrect area to draw on...
  destWidth:= Dest.Right - Dest.left;
  destHeight:= Dest.Top - Dest.Bottom;

  // First draw the item background, in highlight colour if needed
  IF State * [odSelected] <> [] THEN
    Canvas.Brush.Color := clHighLight
  ELSE
    Canvas.Brush.Color := Color;
  Canvas.FillRect( Dest, Canvas.Brush.Color );

  X:= Dest.left;

  // I don't know why but the bitmap colour is affected by the pen colour ?!
  Canvas.Pen.Color := clBlack;

  Item:= Items.Objects[ Index ] as TCheckListBoxData;

  idx:= longint( Item.Checked );
  Bitmap:= FBitmapList.Bitmaps[ idx ];
  Canvas.Draw( X + 2,
               Dest.bottom + ( ItemHeight - Bitmap.Height ) div 2,
               Bitmap );

  inc( X, 20 );
  // Draw string
  s := Items[Index];

  Canvas.GetTextExtent( s, textWidth, textHeight);

  // Centre the text vertically in the available space
  textY:= Dest.Bottom + ((destHeight - textHeight) DIV 2);
  IF textY < Dest.Bottom THEN
    textY:= Dest.Bottom;

  Canvas.Pen.Color := PenColor;
  Canvas.TextOut( X, TextY, s);

End;

Procedure TCustomCheckListBox.CharEvent( Var key:Char;
                                         RepeatCount:Byte);
Begin
  If key= ' ' Then
    Checked[ ItemIndex ]:= not Checked[ ItemIndex ];
  Inherited CharEvent( key, RepeatCount );
End;

Function TCustomCheckListBox.GetChecked(Index:LongInt):boolean;
var
  Item: TCheckListBoxData;
Begin
  Item:= Items.Objects[ Index ] as TCheckListBoxData;
  Result:= Item.Checked;
End;

Procedure TCustomCheckListBox.SetChecked(Index:LongInt;Value:boolean);
var
  Item: TCheckListBoxData;
Begin
  Item:= Items.Objects[ Index ] as TCheckListBoxData;
  Item.Checked:= Value;
  Invalidate;
End;

Procedure TCustomCheckListBox.CheckCheckboxHit( X, Y: longint );
Var
  index: longint;
  p: TPoint;
Begin
  if X < 20 then
  begin
    p.X:= X;
    p.Y:= Y;
    index:= ItemAtPos( p, true );
    if index<>-1 then
      Checked[ index ]:= not Checked[ index ];
  end;
end;

Procedure TCustomCheckListBox.MouseClick( Button: TMouseButton;
                                          ShiftState: TShiftState;
                                          X, Y: longint );
Begin
  CheckCheckboxHit( X, Y );
  Inherited MouseClick( Button, ShiftState, X, Y );
End;

Procedure TCustomCheckListBox.MouseDblClick( Button: TMouseButton;
                                             ShiftState: TShiftState;
                                             X, Y: longint );
Begin
  CheckCheckboxHit( X, Y );
  Inherited MouseDblClick( Button, ShiftState, X, Y );
End;

Function TCustomCheckListBox.GetString( index: longint ): string;
Begin
  Result:= Items[ index ];
End;

Procedure TCustomCheckListBox.SetString( Index: LongInt; Value: string );
Begin
  Items[ index ]:= Value;
End;

Function TCustomCheckListBox.GetObject( Index: LongInt ): TObject;
var
  Item: TCheckListBoxData;
Begin
  Item:= Items.Objects[ Index ] as TCheckListBoxData;
  Result:= Item.Data;
End;

Procedure TCustomCheckListBox.SetObject( Index: LongInt; Value: TObject );
var
  Item: TCheckListBoxData;
Begin
  Item:= Items.Objects[ Index ] as TCheckListBoxData;
  Item.Data:= Value;
End;

Function TCustomCheckListBox.AddItemObject( TheString: string;
                                            TheObject: TObject;
                                            Checked: boolean ): longint;
var
  Item: TCheckListBoxData;
Begin
  Item:= TCheckListBoxData.Create;
  Item.Data:= TheObject;
  Item.Checked:= Checked;
  Result:= Items.AddObject( TheString, Item );
End;

Procedure TCustomCheckListBox.Clear;
var
  i: longint;
  Item: TCheckListBoxData;
Begin
  for i:= 0 to Items.Count - 1 do
  begin
    Item:= Items.Objects[ i ] as TCheckListBoxData;
    Item.Destroy;
  end;
  Inherited Clear;
End;

Function TCustomCheckListBox.GetItemCount: longint;
Begin
  Result:= Items.Count;
End;

Function TCustomCheckListBox.GetSelectedObject: TObject;
Begin
  if ItemIndex<>-1 then
    Result:= Objects[ ItemIndex ]
  else
    Result:= nil;
End;

Procedure TCustomCheckListBox.SetSelectedObject( Value: TObject );
Var
  Index: longint;
Begin
  Index:= Items.IndexOfObject( Value );
  if Index <> -1 then
    ItemIndex:= Index;
End;

Function TCustomCheckListBox.GetSelectedString: string;
Begin
  if ItemIndex<>-1 then
    Result:= Items[ ItemIndex ]
  else
    Result:= '';
End;

Function TCustomCheckListBox.GetCheckedCount: longint;
var
  i: longint;
  Item: TCheckListBoxData;
Begin
  Result:= 0;
  for i:= 0 to Items.Count - 1 do
  begin
    Item:= Items.Objects[ i ] as TCheckListBoxData;
    if Item.Checked then
      inc( Result );
  end;
end;

Procedure TCustomCheckListBox.AddCheckedItems( Dest: TStrings );
var
  i: longint;
  Item: TCheckListBoxData;
Begin
  for i:= 0 to Items.Count - 1 do
  begin
    Item:= Items.Objects[ i ] as TCheckListBoxData;
    if Item.Checked then
      Dest.AddObject( Items[ i ],
                      Item.Data );
  end;
end;

Procedure TCustomCheckListBox.GetCheckedItems( Dest: TStrings );
begin
  Dest.Clear;
  AddCheckedItems( Dest );
end;

Begin
End.



