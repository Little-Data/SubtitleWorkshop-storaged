{*
 *  URUWorks Subtitle API
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

unit UWSubtitleAPI.Formats.IAuthor;

// -----------------------------------------------------------------------------

interface

uses
  SysUtils, UWSubtitleAPI, UWSystem.TimeUtils, UWSystem.StrUtils,
  UWSystem.SysUtils, UWSubtitleAPI.Formats;

type

  { TUWIAuthor }

  TUWIAuthor = class(TUWSubtitleCustomFormat)
  public
    function Name: String; override;
    function Format: TUWSubtitleFormats; override;
    function Extension: String; override;
    function HasStyleSupport: Boolean; override;
    function IsMine(const SubtitleFile: TUWStringList; const Row: Integer): Boolean; override;
    function LoadSubtitle(const SubtitleFile: TUWStringList; const FPS: Single; var Subtitles: TUWSubtitles): Boolean; override;
    function SaveSubtitle(const FileName: String; const FPS: Single; const Encoding: TEncoding; const Subtitles: TUWSubtitles; const FromItem: Integer = -1; const ToItem: Integer = -1): Boolean; override;
    function ToText(const Subtitles: TUWSubtitles): String; override;
  end;

// -----------------------------------------------------------------------------

implementation

uses UWSubtitleAPI.ExtraInfo, UWSubtitleAPI.Tags;

// -----------------------------------------------------------------------------

function TUWIAuthor.Name: String;
begin
  Result := IndexToName(Integer(Format));
end;

// -----------------------------------------------------------------------------

function TUWIAuthor.Format: TUWSubtitleFormats;
begin
  Result := TUWSubtitleFormats.sfIAuthorScript;
end;

// -----------------------------------------------------------------------------

function TUWIAuthor.Extension: String;
begin
  Result := '*.txt';
end;

// -----------------------------------------------------------------------------

function TUWIAuthor.HasStyleSupport: Boolean;
begin
  Result := False;
end;

// -----------------------------------------------------------------------------

function TUWIAuthor.IsMine(const SubtitleFile: TUWStringList; const Row: Integer): Boolean;
begin
  if (Pos('BMPFILE:', SubtitleFile[Row]) = 1) or
     (Pos('TIME:', SubtitleFile[Row]) = 1) or
     (Pos('STARTTIME:', SubtitleFile[Row]) = 1) then
    Result := True
  else
    Result := False;
end;

// -----------------------------------------------------------------------------

function TUWIAuthor.LoadSubtitle(const SubtitleFile: TUWStringList; const FPS: Single; var Subtitles: TUWSubtitles): Boolean;
var
  i, c, u     : Integer;
  InitialTime : Integer;
  FinalTime   : Integer;
  DecimalSep  : Char;
  Text        : String;
begin
  Result := False;

  c := 0;
  u := 0;

  with FormatSettings do
  begin
    DecimalSep       := DecimalSeparator;
    DecimalSeparator := '.';
  end;

  try
    for i := SubtitleFile.Count-1 downto 0 do
    begin
      if (Pos('BMPFILE:', SubtitleFile[i]) = 0) and
         ((Pos('TIME:', SubtitleFile[i]) = 1) and ((Pos('DISABLE_OGT', SubtitleFile[i]) = 0))) or
         (Pos('*', SubtitleFile[i]) = 1) then
        SubtitleFile.Delete(i);
    end;

    for i := 0 to SubtitleFile.Count-1 do
    begin
      if (Pos('BMPFILE:', SubtitleFile[i]) = 1) then
      begin
        Text := Trim(Copy(SubtitleFile[i], 9, Length(SubtitleFile[i])));
        if (Pos('STARTTIME:', SubtitleFile[i+1]) = 1) then
        begin
          InitialTime := Round((StrToFloat(Trim(Copy(SubtitleFile[i+1], 11, Length(SubtitleFile[i+1]))))+(256*c))*1000);

          if InitialTime > u then
            u := InitialTime
          else
          begin
            u := InitialTime;
            Inc(c);
          end;
          if (Pos('TIME:', SubtitleFile[i+2]) = 1) then
            FinalTime := Round((StrToFloat(Trim(Copy(SubtitleFile[i+2], 6, Pos(' ', SubtitleFile[i+2]))))+(256*c))*1000)
          else
            FinalTime := InitialTime + 2000;

          if (InitialTime > -1) and (FinalTime > -1) then
            Subtitles.Add(InitialTime, FinalTime, Text, '');
        end;
      end;
    end;
  finally
    Result := Subtitles.Count > 0;
    with FormatSettings do DecimalSeparator := DecimalSep;
  end;
end;

// -----------------------------------------------------------------------------

function TUWIAuthor.SaveSubtitle(const FileName: String; const FPS: Single; const Encoding: TEncoding; const Subtitles: TUWSubtitles; const FromItem: Integer = -1; const ToItem: Integer = -1): Boolean;
var
  SubFile : TUWStringList;
  sTime      : Single;
  i, c       : Integer;
  tmpNum     : String;
  DecimalSep : Char;
begin
  Result  := False;
  SubFile := TUWStringList.Create;
  try
    with FormatSettings do
    begin
      DecimalSep       := DecimalSeparator;
      DecimalSeparator := '.';
    end;
    c := 1;

    for i := FromItem to ToItem do
    begin
      Subtitles.Text[i] := RemoveSWTags(Subtitles.Text[i]);

      sTime := Subtitles[i].InitialTime / 1000;
      if sTime > (256*c) Then inc(c);

      sTime  := sTime - (256*(c-1));
      tmpNum := LimitDecimals(sTime, 2);

      if Pos('.',tmpNum) = 0 then
        tmpNum := tmpNum + '.00';
      if Length(Copy(tmpNum,Pos('.',tmpNum)+1,Length(tmpNum))) < 2 then
        tmpNum := tmpNum + '0';

      SubFile.Add('BMPFILE: ' + ReplaceEnters(Subtitles[i].Text,' '), False);
      SubFile.Add('', False);
      SubFile.Add('STARTTIME: ' + tmpNum, False);
      SubFile.Add('', False);
      SubFile.Add(SysUtils.Format('TIME: %s SETCOLOR Primary 0, 16, 128, 128',[tmpNum]), False);
      SubFile.Add('', False);
      SubFile.Add(SysUtils.Format('TIME: %s SETCOLOR Primary 1, 234, 128, 128',[tmpNum]), False);
      SubFile.Add('', False);
      SubFile.Add(SysUtils.Format('TIME: %s SETCOLOR Primary 2, 16, 128, 128',[tmpNum]), False);
      SubFile.Add('', False);
      SubFile.Add(SysUtils.Format('TIME: %s SETCOLOR Primary 3, 125, 128, 128',[tmpNum]), False);
      SubFile.Add('', False);
      SubFile.Add(SysUtils.Format('TIME: %s SETCOLOR Highlight 0, 16, 128, 128',[tmpNum]), False);
      SubFile.Add('', False);
      SubFile.Add(SysUtils.Format('TIME: %s SETCOLOR Highlight 1, 209, 146, 17',[tmpNum]), False);
      SubFile.Add('', False);
      SubFile.Add(SysUtils.Format('TIME: %s SETCOLOR Highlight 2, 81, 239, 91',[tmpNum]), False);
      SubFile.Add('', False);
      SubFile.Add(SysUtils.Format('TIME: %s SETCOLOR Highlight 3, 144, 35, 54',[tmpNum]), False);
      SubFile.Add('', False);
      SubFile.Add(SysUtils.Format('TIME: %s region 207, 170 to 432, 190',[tmpNum]), False);
      SubFile.Add('', False);
      SubFile.Add(SysUtils.Format('TIME: %s SETBLEND Primary 0, 15, 15, 15',[tmpNum]), False);
      SubFile.Add('', False);
      SubFile.Add(SysUtils.Format('TIME: %s SETBLEND Hightlight 0, 15, 15, 15',[tmpNum]), False);
      SubFile.Add('', False);
      SubFile.Add(SysUtils.Format('TIME: %s FIELDINDEX 0, 1',[tmpNum]), False);
      SubFile.Add('', False);
      SubFile.Add(SysUtils.Format('TIME: %s ENABLE_OGT',[tmpNum]), False);
      SubFile.Add('', False);

      sTime := Subtitles[i].FinalTime / 1000;
      sTime := sTime - (256*(c-1));

      tmpNum := LimitDecimals(sTime, 2);

      if Pos('.',tmpNum) = 0 then
        tmpNum := tmpNum + '.00';
      if Length(Copy(tmpNum,Pos('.',tmpNum)+1,Length(tmpNum))) < 2 then
        tmpNum := tmpNum + '0';

      SubFile.Add(SysUtils.Format('TIME: %s DISABLE_OGT',[tmpNum]), False);
      SubFile.Add('', False);
      SubFile.Add('************ Page #' + IntToStr(i+1) + ' Finished ***************', False);
      SubFile.Add('', False);
    end;

    try
      with FormatSettings do DecimalSeparator := DecimalSep;
      SubFile.SaveToFile(FileName, Encoding);
      Result := True;
    except
    end;
  finally
    SubFile.Free;
  end;
end;

// -----------------------------------------------------------------------------

function TUWIAuthor.ToText(const Subtitles: TUWSubtitles): String;
begin
  Result := '';
end;

// -----------------------------------------------------------------------------

end.
