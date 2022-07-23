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

unit UWSubtitleAPI.Formats.KaraokeLyricsVKT;

// -----------------------------------------------------------------------------

interface

uses
  SysUtils, UWSubtitleAPI, UWSystem.TimeUtils, UWSystem.StrUtils,
  UWSubtitleAPI.Formats;

type

  { TUWKaraokeLyricsVKT }

  TUWKaraokeLyricsVKT = class(TUWSubtitleCustomFormat)
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

function TUWKaraokeLyricsVKT.Name: String;
begin
  Result := IndexToName(Integer(Format));
end;

// -----------------------------------------------------------------------------

function TUWKaraokeLyricsVKT.Format: TUWSubtitleFormats;
begin
  Result := TUWSubtitleFormats.sfKaraokeLyricsLRC;
end;

// -----------------------------------------------------------------------------

function TUWKaraokeLyricsVKT.Extension: String;
begin
  Result := '*.lrc';
end;

// -----------------------------------------------------------------------------

function TUWKaraokeLyricsVKT.HasStyleSupport: Boolean;
begin
  Result := False;
end;

// -----------------------------------------------------------------------------

function TUWKaraokeLyricsVKT.IsMine(const SubtitleFile: TUWStringList; const Row: Integer): Boolean;
begin
  if (TimeInFormat(Copy(SubtitleFile[Row], 2, 8), 'mm:ss.zz')) and
     (Copy(SubtitleFile[Row], 1, 1) = '[') and
     (Copy(SubtitleFile[Row], 10, 1) = ']') then
    Result := True
  else
    Result := False;
end;

// -----------------------------------------------------------------------------

function TUWKaraokeLyricsVKT.LoadSubtitle(const SubtitleFile: TUWStringList; const FPS: Single; var Subtitles: TUWSubtitles): Boolean;
var
  i           : Integer;
  InitialTime : Integer;
  FinalTime   : Integer;
  Text        : String;
begin
  Result := False;
  try
    for i := 0 to SubtitleFile.Count-1 do
    begin
      InitialTime := StringToTime(Copy(SubtitleFile[i], 2, Pos(']', SubtitleFile[i]) - 2), True);
      if i+1 <= (SubtitleFile.Count-1) then
        FinalTime := StringToTime(Copy(SubtitleFile[i+1], 2, Pos(']', SubtitleFile[i+1]) - 2), True)
      else
        FinalTime := InitialTime + 2000;

      Text := Copy(SubtitleFile[i], Pos(']', SubtitleFile[i]) + 1, Length(SubtitleFile[i]));

      if (InitialTime > -1) and (FinalTime > -1) then
        Subtitles.Add(InitialTime, FinalTime, Text, '');
    end;
  finally
    Result := Subtitles.Count > 0;
  end;
end;

// -----------------------------------------------------------------------------

function TUWKaraokeLyricsVKT.SaveSubtitle(const FileName: String; const FPS: Single; const Encoding: TEncoding; const Subtitles: TUWSubtitles; const FromItem: Integer = -1; const ToItem: Integer = -1): Boolean;
var
  SubFile : TUWStringList;
  i       : Integer;
begin
  Result  := False;
  SubFile := TUWStringList.Create;
  try
    SubFile.Add('[ti:Project title]', False);
    SubFile.Add('[ar:Project author]', False);
    SubFile.Add('[la:af]', False);
    SubFile.Add('Project title', False);
    SubFile.Add('', False);

    for i := FromItem to ToItem do
    begin
      Subtitles.Text[i] := RemoveSWTags(Subtitles.Text[i]);
      SubFile.Add('[' + TimeToString(Subtitles[i].InitialTime, 'mm:ss.zz') + ']' + ReplaceEnters(Subtitles[i].Text, ''), False);
      SubFile.Add('[' + TimeToString(Subtitles[i].FinalTime, 'mm:ss.zz') + ']');
    end;

    try
      SubFile.SaveToFile(FileName, Encoding);
      Result := True;
    except
    end;
  finally
    SubFile.Free;
  end;
end;

// -----------------------------------------------------------------------------

function TUWKaraokeLyricsVKT.ToText(const Subtitles: TUWSubtitles): String;
begin
  Result := '';
end;

// -----------------------------------------------------------------------------

end.
