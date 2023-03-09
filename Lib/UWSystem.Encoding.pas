{*
 *  URUWorks Lazarus Encoding
 *
 *  The contents of this file are used with permission, subject to
 *  the Mozilla Public License Version 1.1 (the "License"); you may
 *  not use this file except in compliance with the License. You may
 *  obtain a copy of the License at
 *  http://www.mozilla.org/MPL/MPL-1.1.html
 *
 *  Software distributed under the License is distributed on an
 *  "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 *  implied. See the License for the specific language governing
 *  rights and limitations under the License.
 *
 *  Copyright (C) 2001-2022 URUWorks, uruworks@gmail.com.
 *
 *}

unit UWSystem.Encoding;

// -----------------------------------------------------------------------------

{$C-}

interface

uses
  {$IFDEF MSWINDOWS}Windows, {$ENDIF} SysUtils, Classes, UWSystem.StrUtils;

type
  TCPData = record
    CPID   : Integer;
    CPName : String;
  end;

const
  MaxEncodings = 140;

  Encodings: array[0..MaxEncodings-1] of TCPData =
  (
    (CPID: 37; CPName: 'IBM037'),
    (CPID: 437; CPName: 'IBM437'),
    (CPID: 500; CPName: 'IBM500'),
    (CPID: 708; CPName: 'ASMO-708'),
    (CPID: 720; CPName: 'DOS-720'),
    (CPID: 737; CPName: 'ibm737'),
    (CPID: 775; CPName: 'ibm775'),
    (CPID: 850; CPName: 'ibm850'),
    (CPID: 852; CPName: 'ibm852'),
    (CPID: 855; CPName: 'IBM855'),
    (CPID: 857; CPName: 'ibm857'),
    (CPID: 858; CPName: 'IBM00858'),
    (CPID: 860; CPName: 'IBM860'),
    (CPID: 861; CPName: 'ibm861'),
    (CPID: 862; CPName: 'DOS-862'),
    (CPID: 863; CPName: 'IBM863'),
    (CPID: 864; CPName: 'IBM864'),
    (CPID: 865; CPName: 'IBM865'),
    (CPID: 866; CPName: 'cp866'),
    (CPID: 869; CPName: 'ibm869'),
    (CPID: 870; CPName: 'IBM870'),
    (CPID: 874; CPName: 'windows-874'),
    (CPID: 875; CPName: 'cp875'),
    (CPID: 932; CPName: 'shift_jis'),
    (CPID: 936; CPName: 'gb2312'),
    (CPID: 949; CPName: 'ks_c_5601-1987'),
    (CPID: 950; CPName: 'big5'),
    (CPID: 1026; CPName: 'IBM1026'),
    (CPID: 1047; CPName: 'IBM01047'),
    (CPID: 1140; CPName: 'IBM01140'),
    (CPID: 1141; CPName: 'IBM01141'),
    (CPID: 1142; CPName: 'IBM01142'),
    (CPID: 1143; CPName: 'IBM01143'),
    (CPID: 1144; CPName: 'IBM01144'),
    (CPID: 1145; CPName: 'IBM01145'),
    (CPID: 1146; CPName: 'IBM01146'),
    (CPID: 1147; CPName: 'IBM01147'),
    (CPID: 1148; CPName: 'IBM01148'),
    (CPID: 1149; CPName: 'IBM01149'),
    (CPID: 1200; CPName: 'utf-16'),
    (CPID: 1201; CPName: 'unicode'),
    (CPID: 1250; CPName: 'windows-1250'),
    (CPID: 1251; CPName: 'windows-1251'),
    (CPID: 1252; CPName: 'Windows-1252'),
    (CPID: 1253; CPName: 'windows-1253'),
    (CPID: 1254; CPName: 'windows-1254'),
    (CPID: 1255; CPName: 'windows-1255'),
    (CPID: 1256; CPName: 'windows-1256'),
    (CPID: 1257; CPName: 'windows-1257'),
    (CPID: 1258; CPName: 'windows-1258'),
    (CPID: 1361; CPName: 'Johab'),
    (CPID: 10000; CPName: 'macintosh'),
    (CPID: 10001; CPName: 'x-mac-japanese'),
    (CPID: 10002; CPName: 'x-mac-chinesetrad'),
    (CPID: 10003; CPName: 'x-mac-korean'),
    (CPID: 10004; CPName: 'x-mac-arabic'),
    (CPID: 10005; CPName: 'x-mac-hebrew'),
    (CPID: 10006; CPName: 'x-mac-greek'),
    (CPID: 10007; CPName: 'x-mac-cyrillic'),
    (CPID: 10008; CPName: 'x-mac-chinesesimp'),
    (CPID: 10010; CPName: 'x-mac-romanian'),
    (CPID: 10017; CPName: 'x-mac-ukrainian'),
    (CPID: 10021; CPName: 'x-mac-thai'),
    (CPID: 10029; CPName: 'x-mac-ce'),
    (CPID: 10079; CPName: 'x-mac-icelandic'),
    (CPID: 10081; CPName: 'x-mac-turkish'),
    (CPID: 10082; CPName: 'x-mac-croatian'),
    (CPID: 12000; CPName: 'utf-32'),
    (CPID: 12001; CPName: 'utf-32BE'),
    (CPID: 20000; CPName: 'x-Chinese-CNS'),
    (CPID: 20001; CPName: 'x-cp20001'),
    (CPID: 20002; CPName: 'x-Chinese-Eten'),
    (CPID: 20003; CPName: 'x-cp20003'),
    (CPID: 20004; CPName: 'x-cp20004'),
    (CPID: 20005; CPName: 'x-cp20005'),
    (CPID: 20105; CPName: 'x-IA5'),
    (CPID: 20106; CPName: 'x-IA5-German'),
    (CPID: 20107; CPName: 'x-IA5-Swedish'),
    (CPID: 20108; CPName: 'x-IA5-Norwegian'),
    (CPID: 20127; CPName: 'us-ascii'),
    (CPID: 20261; CPName: 'x-cp20261'),
    (CPID: 20269; CPName: 'x-cp20269'),
    (CPID: 20273; CPName: 'IBM273'),
    (CPID: 20277; CPName: 'IBM277'),
    (CPID: 20278; CPName: 'IBM278'),
    (CPID: 20280; CPName: 'IBM280'),
    (CPID: 20284; CPName: 'IBM284'),
    (CPID: 20285; CPName: 'IBM285'),
    (CPID: 20290; CPName: 'IBM290'),
    (CPID: 20297; CPName: 'IBM297'),
    (CPID: 20420; CPName: 'IBM420'),
    (CPID: 20423; CPName: 'IBM423'),
    (CPID: 20424; CPName: 'IBM424'),
    (CPID: 20833; CPName: 'x-EBCDIC-KoreanExtended'),
    (CPID: 20838; CPName: 'IBM-Thai'),
    (CPID: 20866; CPName: 'koi8-r'),
    (CPID: 20871; CPName: 'IBM871'),
    (CPID: 20880; CPName: 'IBM880'),
    (CPID: 20905; CPName: 'IBM905'),
    (CPID: 20924; CPName: 'IBM00924'),
    (CPID: 20932; CPName: 'EUC-JP'),
    (CPID: 20936; CPName: 'x-cp20936'),
    (CPID: 20949; CPName: 'x-cp20949'),
    (CPID: 21025; CPName: 'cp1025'),
    (CPID: 21866; CPName: 'koi8-u'),
    (CPID: 28591; CPName: 'iso-8859-1'),
    (CPID: 28592; CPName: 'iso-8859-2'),
    (CPID: 28593; CPName: 'iso-8859-3'),
    (CPID: 28594; CPName: 'iso-8859-4'),
    (CPID: 28595; CPName: 'iso-8859-5'),
    (CPID: 28596; CPName: 'iso-8859-6'),
    (CPID: 28597; CPName: 'iso-8859-7'),
    (CPID: 28598; CPName: 'iso-8859-8'),
    (CPID: 28599; CPName: 'iso-8859-9'),
    (CPID: 28603; CPName: 'iso-8859-13'),
    (CPID: 28605; CPName: 'iso-8859-15'),
    (CPID: 29001; CPName: 'x-Europa'),
    (CPID: 38598; CPName: 'iso-8859-8-i'),
    (CPID: 50220; CPName: 'iso-2022-jp'),
    (CPID: 50221; CPName: 'csISO2022JP'),
    (CPID: 50222; CPName: 'iso-2022-jp'),
    (CPID: 50225; CPName: 'iso-2022-kr'),
    (CPID: 50227; CPName: 'x-cp50227'),
    (CPID: 51932; CPName: 'euc-jp'),
    (CPID: 51936; CPName: 'EUC-CN'),
    (CPID: 51949; CPName: 'euc-kr'),
    (CPID: 52936; CPName: 'hz-gb-2312'),
    (CPID: 54936; CPName: 'GB18030'),
    (CPID: 57002; CPName: 'x-iscii-de'),
    (CPID: 57003; CPName: 'x-iscii-be'),
    (CPID: 57004; CPName: 'x-iscii-ta'),
    (CPID: 57005; CPName: 'x-iscii-te'),
    (CPID: 57006; CPName: 'x-iscii-as'),
    (CPID: 57007; CPName: 'x-iscii-or'),
    (CPID: 57008; CPName: 'x-iscii-ka'),
    (CPID: 57009; CPName: 'x-iscii-ma'),
    (CPID: 57010; CPName: 'x-iscii-gu'),
    (CPID: 57011; CPName: 'x-iscii-pa'),
    (CPID: 65000; CPName: 'utf-7'),
    (CPID: 65001; CPName: 'utf-8')
  );

{$IFDEF MSWINDOWS}
function CharsetToCodePage(ciCharset: Cardinal): Cardinal;
function StringToWideStringEx(const S: AnsiString; CodePage: Word = CP_ACP): String;
function WideStringToStringEx(const WS: String; CodePage: Word = CP_ACP): AnsiString;
function TranslateString(const S: String; CP1, CP2: Word): String;
{$ENDIF}
function GetEncodingString(const CPID: Integer): String;
function GetEncodingInteger(const CPName: String): Integer;
function GetEncodingIndex(const CPID: Integer): Integer;

function GetEncodingFromFile(const FileName: String): TEncoding;

// -----------------------------------------------------------------------------

implementation

// -----------------------------------------------------------------------------

{$IFDEF MSWINDOWS}
function CharsetToCodePage(ciCharset: Cardinal): Cardinal;
var
  C: TCharsetInfo;
begin
  TranslateCharsetInfo(ciCharset, C, TCI_SRCCHARSET);
  Result := C.ciACP;
end;

// -----------------------------------------------------------------------------

function StringToWideStringEx(const S: AnsiString; CodePage: Word = CP_ACP): String;
var
  l: integer;
begin
  if s = '' then
    Result := ''
  else
  begin
    l := MultiByteToWideChar(CodePage, MB_PRECOMPOSED, PAnsiChar(@s[1]), - 1, NIL, 0);
    SetLength(Result, l - 1);
    if l > 1 then
      MultiByteToWideChar(CodePage, MB_PRECOMPOSED, PAnsiChar(@s[1]),
        - 1, PWideChar(@Result[1]), l - 1);
  end;
end;

// -----------------------------------------------------------------------------

function WideStringToStringEx(const WS: String; CodePage: Word = CP_ACP): AnsiString;
var
  l: integer;
begin
  if ws = '' then
    Result := ''
  else
  begin
    l := WideCharToMultiByte(CodePage,
      WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR,
      @ws[1], - 1, NIL, 0, NIL, NIL);
    SetLength(Result, l - 1);
    if l > 1 then
      WideCharToMultiByte(codePage,
        WC_COMPOSITECHECK or WC_DISCARDNS or WC_SEPCHARS or WC_DEFAULTCHAR,
        @ws[1], - 1, @Result[1], l - 1, NIL, NIL);
  end;
end;

// -----------------------------------------------------------------------------

function TranslateString(const S: String; CP1, CP2: Word): String;
begin
  Result := WideStringToStringEx(StringToWideStringEx(S, CP1), CP2);
end;
{$ENDIF}

// -----------------------------------------------------------------------------

function GetEncodingString(const CPID: Integer): String;
var
  I: Integer;
begin
  Result := 'iso-8859-1'; //default encoding

  for I := 0 to MaxEncodings - 1 do
    if Encodings[I].CPID = CPID then
    begin
      Result := Encodings[I].CPName;
      Break;
    end;
end;

// -----------------------------------------------------------------------------

function GetEncodingInteger(const CPName: String): Integer;
var
  I: Integer;
begin
  Result := 28591; //default encoding

  for I := 0 to MaxEncodings - 1 do
    if LowerCase(Encodings[I].CPName) = LowerCase(CPName) then
    begin
      Result := Encodings[I].CPID;
      Break;
    end;
end;

// -----------------------------------------------------------------------------

function GetEncodingIndex(const CPID: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;

  for I := 0 to MaxEncodings - 1 do
    if Encodings[I].CPID = CPID then
    begin
      Result := I;
      Break;
    end;
end;

// -----------------------------------------------------------------------------

function IsUTF8(const Buffer: TBytes; out CouldBeUTF8: Boolean): Boolean;
var
  utf8count, i: Integer;
  b: Byte;
begin
  CouldBeUTF8 := False;
  utf8count := 0;
  i := 0;
  while (i < Length(Buffer) - 3) do
  begin
    b := Buffer[i];
    if b > 127 then
    begin
      if (b >= 194) and (b <= 223) and (Buffer[i+1] >= 128) and (Buffer[i+1] <= 191) then
      begin
        // 2-byte sequence
        inc(utf8count);
        inc(i);
      end
      else if (b >= 224) and (b <= 239) and (Buffer[i+1] >= 128) and (Buffer[i+1] <= 191) and (Buffer[i+2] >= 128) and (Buffer[i+2] <= 191) then
      begin
        // 3-byte sequence
        inc(utf8count);
        inc(i, 2);
      end
      else if (b >= 240) and (b <= 244) and (Buffer[i+1] >= 128) and (Buffer[i+1] <= 191) and (Buffer[i+2] >= 128) and (Buffer[i+2] <= 191) and (Buffer[i+3] >= 128) and (Buffer[i+3] <= 191) then
      begin
        // 4-byte sequence
        inc(utf8count);
        inc(i, 3);
      end
      else
      begin
        Result := False;
        Exit;
      end;
    end;
    inc(i);
  end;

  CouldBeUTF8 := True;
  Result := (utf8count > 0);
end;

// -----------------------------------------------------------------------------

function GetStringCount(const ASourceString: String; const AWords: array of String): Integer;
begin
  Result := StringCountRE('\b(' + String.Join('|', AWords) + ')\b', ASourceString);
end;

// -----------------------------------------------------------------------------

function DetectAnsiEncoding(const Buffer: TBytes): TEncoding;
const
  _Russian: Array of String = ('что', 'быть', 'весь', 'этот', 'один', 'такой');
  _Bulgarian: Array of String = ('Какво', 'тук', 'може', 'Как', 'Ваше', 'какво');
  _SerbianCyrillic: Array of String = ('сам', 'али', 'није', 'само', 'ово', 'како', 'добро', 'све', 'тако', 'ће', 'могу', 'ћу', 'зашто', 'нешто', 'за', 'шта', 'овде', 'бити', 'чини', 'учениче', 'побегне', 'остати', 'Један', 'Назад', 'Молим');
  _Greek: Array of String = ('μου', '[Εε]ίναι', 'αυτό', 'Τόμπυ', 'καλά', 'Ενταξει', 'πρεπει', 'Λοιπον', 'τιποτα', 'ξερεις');
  _CroatianAndSerbian: Array of String = ('sam', 'ali', 'nije', 'Nije', 'samo', 'ovo', 'kako', 'dobro', 'Dobro', 'sve', 'tako', 'će', 'mogu', 'ću', 'zašto', 'nešto', 'za', 'misliš', 'možeš', 'možemo', 'ništa', 'znaš', 'ćemo', 'znam');
  _CzechAndSlovak: Array of String = ('[Oo]n[ao]?', '[Jj]?si', '[Aa]le', '[Tt]en(to)?', '[Rr]ok', '[Tt]ak', '[Aa]by', '[Tt]am', '[Jj]ed(en|na|no)', '[Nn]ež', '[Aa]ni', '[Bb]ez', '[Dd]obr[ýáé]', '[Vv]šak', '[Cc]el[ýáé]', '[Nn]ov[ýáé]', '[Dd]ruh[ýáé]', 'jsem', 'poøádku', 'Pojïme', 'háje', 'není', 'Jdeme', 'všecko', 'jsme', 'Prosím', 'Vezmi', 'když', 'Takže', 'Dìkuji', 'prechádzku', 'všetko', 'Poïme', 'potom', 'Takže', 'Neviem', 'budúcnosti', 'trochu');
  _Czech: Array of String = ('.*[Řř].*', '.*[ůě].*', '[Bb]ýt', '[Jj]sem', '[Jj]si', '[Jj]á', '[Mm]ít', '[Aa]no', '[Nn]e',  '[Nn]ic', '[Dd]en', '[Jj]en', '[Cc]o', '[Jj]ak[o]?', '[Nn]ebo',  '[Pp]ři', '[Pp]ro', '[Pp]řed.*', '[Jj](ít|du|de|deme|dou)', '[Mm]ezi',  '[Jj]eště', '[Čč]lověk', '[Pp]odle', '[Dd]alší');
  _Hungarian: Array of String = ('hogy', 'lesz', 'tudom', 'vagy', 'mondtam', 'még', 'vagyok', 'csak', 'Hát', 'felesége', 'Csak', 'utána', 'jött', 'Miért', 'Akkor', 'magát', 'holnap', 'Tudja', 'Köszönöm', 'élet', 'Örvendek', 'vissza', 'hogy', 'tudom', 'Rendben', 'Istenem', 'Gyerünk', 'értem', 'vagyok', 'hiszem', 'történt', 'rendben', 'olyan', 'őket', 'vannak', 'mindig', 'Kérlek', 'Gyere', 'kicsim', 'vagyunk');
  _Latvian: Array of String = ('Paldies', 'neesmu ', 'nezinu', 'viòð', 'viņš', 'viņu', 'kungs', 'esmu', 'Viņš', 'Velns', 'viņa', 'dievs', 'Pagaidi', 'varonis', 'agrāk', 'varbūt');
  _Arabic: Array of String = ('من', 'هل', 'لا', 'في', 'لقد', 'ما', 'ماذا', 'يا', 'هذا', 'إلى', 'على', 'أنا', 'أنت', 'حسناً', 'أيها', 'كان', 'كيف', 'يكون', 'هذه', 'هذان', 'الذي', 'التي', 'الذين', 'هناك', 'هنالك');
  _Hebrew: Array of String = ('אתה', 'אולי', 'הוא', 'בסדר', 'יודע', 'טוב');

var
  Encoding, Enc : TEncoding;
  Text          : String;
  WordMinCount  : Integer;
begin
  Result := NIL;

  // Cyrillic
  WordMinCount := Length(Buffer) div 300;
  Encoding := TEncoding.GetEncoding(1251);
  Text := Encoding.GetString(Buffer);
  if (GetStringCount(Text, _Russian) > 5) or
     (GetStringCount(Text, _Bulgarian) > 5) or
     (GetStringCount(Text, _SerbianCyrillic) > WordMinCount) then
  begin
    Result := Encoding;
    Exit;
  end;

  // Greek
  Encoding := TEncoding.GetEncoding(1253);
  Text := Encoding.GetString(Buffer);
  if (GetStringCount(Text, _Greek) > 5) then
  begin
    Result := Encoding;
    Exit;
  end;

  // Central European/Eastern European
  Encoding := TEncoding.GetEncoding(1250);
  Text := Encoding.GetString(Buffer);
  if (GetStringCount(Text, _CroatianAndSerbian) > WordMinCount) or
     (GetStringCount(Text, _CzechAndSlovak) > WordMinCount) or
     (GetStringCount(Text, _Czech) > WordMinCount) or
     (GetStringCount(Text, _Hungarian) > WordMinCount) then
  begin
    Result := Encoding;
    Exit;
  end;

  // Latvian
  Encoding := TEncoding.GetEncoding(1257);
  Text := Encoding.GetString(Buffer);
  if (GetStringCount(Text, _Latvian) > 5) then
  begin
    Result := Encoding;
    Exit;
  end;

  // Arabic
  Encoding := TEncoding.GetEncoding(1256);
  Enc := TEncoding.GetEncoding(1255); // Hebrew
  Text := Encoding.GetString(Buffer);
  if (GetStringCount(Text, _Arabic) > 5) then
  begin
    // Hebrew
    if (GetStringCount(Enc.GetString(Buffer), _Hebrew) > 10) then
    begin
      Result := Enc;
      Exit;
    end;
    Result := Encoding;
    Exit;
  end;
  // Hebrew
  if (GetStringCount(Enc.GetString(Buffer), _Hebrew) > 5) then
  begin
    Result := Enc;
    Exit;
  end;
end;

// -----------------------------------------------------------------------------

function GetEncodingFromFile(const FileName: String): TEncoding;
var
  Stream      : TStream;
  Size        : Integer;
  BOM         : TBytes;
  CouldBeUTF8 : Boolean;
begin
  Result := NIL;
  if not FileExists(FileName) then Exit;

  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    SetLength(BOM, 12);
    Size := Stream.Size - Stream.Position;
    Stream.Position := 0;
    Stream.Read(BOM[0], Length(BOM));

    if (BOM[0] = $EF) and (BOM[1] = $BB) and (BOM[2] = $BF) then
       Result := TEncoding.UTF8
    else if (BOM[0] = $FF) and (BOM[1] = $FE) and (BOM[2] = 0) and (BOM[3] = 0) then
       Result := TEncoding.GetEncoding(12000) // UTF32 (LE)
    else if (BOM[0] = $FF) and (BOM[1] = $FE) then
       Result := TEncoding.Unicode
    else if (BOM[0] = $FE) and (BOM[1] = $FF) then
       Result := TEncoding.BigEndianUnicode
    else if (BOM[0] = 0) and (BOM[1] = 0) and (BOM[2] = $FE) and (BOM[3] = $FF) then
       Result := TEncoding.GetEncoding(12001) // UTF32 (BE)
    else if (BOM[0] = $2B) and (BOM[1] = $2F) and (BOM[2] = $76) and ((BOM[3] = $38) or (BOM[3] = $39) or (BOM[3] = $2B) or (BOM[3] = $2F)) then
       Result := TEncoding.UTF7
    else if Size > Length(BOM) then
    begin
      if Size > 500000 then Size := 500000;
      Stream.Position := 0;
      SetLength(BOM, Size);
      Stream.Read(BOM[0], Size);

      if IsUTF8(BOM, CouldBeUTF8) then
        Result := TEncoding.UTF8
      else if CouldBeUTF8 then
        Result := TEncoding.UTF8
      else
        Result := DetectAnsiEncoding(BOM);
    end;
  finally
    Stream.Free;
  end;
end;

// -----------------------------------------------------------------------------

end.
