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

unit UWSubtitleAPI.Formats.InscriberCG;

// -----------------------------------------------------------------------------

interface

uses
  SysUtils, UWSubtitleAPI, UWSystem.TimeUtils, UWSystem.StrUtils,
  UWSystem.SysUtils, UWSubtitleAPI.Formats;

type

  { TUWInscriberCG }

  TUWInscriberCG = class(TUWSubtitleCustomFormat)
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

function TUWInscriberCG.Name: String;
begin
  Result := IndexToName(Integer(Format));
end;

// -----------------------------------------------------------------------------

function TUWInscriberCG.Format: TUWSubtitleFormats;
begin
  Result := TUWSubtitleFormats.sfInscriberCG;
end;

// -----------------------------------------------------------------------------

function TUWInscriberCG.Extension: String;
begin
  Result := '*.txt';
end;

// -----------------------------------------------------------------------------

function TUWInscriberCG.HasStyleSupport: Boolean;
begin
  Result := False;
end;

// -----------------------------------------------------------------------------

function TUWInscriberCG.IsMine(const SubtitleFile: TUWStringList; const Row: Integer): Boolean;
begin
  if (Pos('@@9', SubtitleFile[Row]) = 1) then
    Result := True
  else
    Result := False;
end;

// -----------------------------------------------------------------------------

function TUWInscriberCG.LoadSubtitle(const SubtitleFile: TUWStringList; const FPS: Single; var Subtitles: TUWSubtitles): Boolean;
var
  i, c        : Integer;
  InitialTime : Integer;
  FinalTime   : Integer;
  Text        : String;
begin
  Result := False;
  try
    for i := 0 to SubtitleFile.Count-1 do
    begin
      if TimeInFormat(Copy(SubtitleFile[i], Length(SubtitleFile[i])-24, 11), 'hh:mm:ss:zz') and
         TimeInFormat(Copy(SubtitleFile[i], Length(SubtitleFile[i])-11, 11), 'hh:mm:ss:zz') then
      begin
        InitialTime := StringToTime(Copy(SubtitleFile[i], Length(SubtitleFile[i])-24, 11));
        FinalTime   := StringToTime(Copy(SubtitleFile[i], Length(SubtitleFile[i])-11, 11));
        Text        := Copy(SubtitleFile[i], 5, Length(SubtitleFile[i])-30);

        c := 1;
        while not TimeInFormat(Copy(SubtitleFile[i-c], Length(SubtitleFile[i-c])-24, 11), 'hh:mm:ss:zz') and
          (i-c > 0) do
        begin
          if SubtitleFile[i-c] = '@@9' then break;
          Text := Copy(SubtitleFile[i-c], 5, Length(SubtitleFile[i-c])) + LineEnding + Text;
          Inc(c);
        end;

        if (InitialTime > -1) and (FinalTime > -1) then
          Subtitles.Add(InitialTime, FinalTime, Text, '');
      end;
    end;
  finally
    Result := Subtitles.Count > 0;
  end;
end;

// -----------------------------------------------------------------------------

function TUWInscriberCG.SaveSubtitle(const FileName: String; const FPS: Single; const Encoding: TEncoding; const Subtitles: TUWSubtitles; const FromItem: Integer = -1; const ToItem: Integer = -1): Boolean;
var
  SubFile : TUWStringList;
  i       : Integer;
begin
  Result  := False;
  SubFile := TUWStringList.Create;
  try
    SubFile.Add('@@9 Title', False);
    SubFile.Add('@@9 Created by URUWorks Subtitle Workshop (uruworks.net)', False);
    SubFile.Add('@@9 STORY:', False);
    SubFile.Add('@@9 LANG: ENG', False);
    for i := 1 to 4 do SubFile.Add('@@9', False);

    for i := FromItem to ToItem do
    begin
      Subtitles.Text[i] := RemoveSWTags(Subtitles.Text[i]);

      SubFile.Add('@@9 ' + ReplaceEnters(Subtitles[i].Text, LineEnding+'@@9 ') +
                  '<' + TimeToString(Subtitles[i].InitialTime, 'hh:mm:ss:zz') + '><'  +
                  TimeToString(Subtitles[i].FinalTime, 'hh:mm:ss:zz') + '>');

      SubFile.Add('', False);
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

function TUWInscriberCG.ToText(const Subtitles: TUWSubtitles): String;
begin
  Result := '';
end;

// -----------------------------------------------------------------------------

end.
