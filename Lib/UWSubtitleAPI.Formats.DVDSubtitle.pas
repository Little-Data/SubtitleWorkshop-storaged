{*
 *  URUWorks Subtitle API
 *
 *  Author  : URUWorks
 *  Website : uruworks.net
 *
 *  The contents of this file are used with permission, subject to
 *  the Mozilla Public License Version 2.0 (the "License"); you may
 *  not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  http://www.mozilla.org/MPL/2.0.html
 *
 *  Software distributed under the License is distributed on an
 *  "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 *  implied. See the License for the specific language governing
 *  rights and limitations under the License.
 *
 *  Copyright (C) 2001-2022 URUWorks, uruworks@gmail.com.
 *}

unit UWSubtitleAPI.Formats.DVDSubtitle;

// -----------------------------------------------------------------------------

interface

uses
  SysUtils, UWSubtitleAPI, UWSystem.TimeUtils, UWSubtitleAPI.Formats;

type

  { TUWDVDSubtitle }

  TUWDVDSubtitle = class(TUWSubtitleCustomFormat)
  public
    function Name: String; override;
    function Format: TUWSubtitleFormats; override;
    function Extension: String; override;
    function HasStyleSupport: Boolean; override;
    function IsMine(const SubtitleFile: TUWStringList; const Row: Integer): Boolean; override;
    function LoadSubtitle(const SubtitleFile: TUWStringList; const FPS: Single; var Subtitles: TUWSubtitles): Boolean; override;
    function SaveSubtitle(const FileName: String; const FPS: Single; const Encoding: TEncoding; const Subtitles: TUWSubtitles; const SubtitleMode: TSubtitleMode; const FromItem: Integer = -1; const ToItem: Integer = -1): Boolean; override;
    function ToText(const Subtitles: TUWSubtitles): String; override;
  end;

// -----------------------------------------------------------------------------

implementation

uses UWSubtitleAPI.ExtraInfo, UWSubtitleAPI.Tags, UWSystem.StrUtils;

// -----------------------------------------------------------------------------

function TUWDVDSubtitle.Name: String;
begin
  Result := IndexToName(Integer(Format));
end;

// -----------------------------------------------------------------------------

function TUWDVDSubtitle.Format: TUWSubtitleFormats;
begin
  Result := TUWSubtitleFormats.sfDVDSubtitle;
end;

// -----------------------------------------------------------------------------

function TUWDVDSubtitle.Extension: String;
begin
  Result := '*.sub';
end;

// -----------------------------------------------------------------------------

function TUWDVDSubtitle.HasStyleSupport: Boolean;
begin
  Result := False;
end;

// -----------------------------------------------------------------------------

function TUWDVDSubtitle.IsMine(const SubtitleFile: TUWStringList; const Row: Integer): Boolean;
begin
  if (Pos('{T ', SubtitleFile[Row]) = 1) and
     (TimeInFormat(Copy(SubtitleFile[Row], 4, 11), 'hh:mm:ss:zz')) then
    Result := True
  else
    Result := False;
end;

// -----------------------------------------------------------------------------

function TUWDVDSubtitle.LoadSubtitle(const SubtitleFile: TUWStringList; const FPS: Single; var Subtitles: TUWSubtitles): Boolean;
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
      if (Pos('{T ', SubtitleFile[i]) = 1) and
         (TimeInFormat(Copy(SubtitleFile[i], 4, 11), 'hh:mm:ss:zz')) then
      begin
        InitialTime := StringToTime(Copy(SubtitleFile[i], 4, 11));
        c    := 1;
        Text := '';
        while (i+c < (SubtitleFile.Count-1)) and (SubtitleFile[i+c] <> '}') do
        begin
          If Text <> '' then
            Text := Text + LineEnding + SubtitleFile[i+c]
          else
            Text := SubtitleFile[i+c];
          Inc(c);
        end;
        c := 1;
        while (i+c < (SubtitleFile.Count-1)) and (Pos('{T ', SubtitleFile[i+c]) = 0) do
          Inc(c);
        FinalTime := StringToTime(Copy(SubtitleFile[i+c], 4, 11));
        if FinalTime = -1 then FinalTime := InitialTime + 2000;

      if (InitialTime > -1) and (FinalTime > -1) then
        Subtitles.Add(InitialTime, FinalTime, Text, '');
      end;
    end;
  finally
    Result := Subtitles.Count > 0;
  end;
end;

// -----------------------------------------------------------------------------

function TUWDVDSubtitle.SaveSubtitle(const FileName: String; const FPS: Single; const Encoding: TEncoding; const Subtitles: TUWSubtitles; const SubtitleMode: TSubtitleMode; const FromItem: Integer = -1; const ToItem: Integer = -1): Boolean;
var
  SubFile   : TUWStringList;
  i         : Integer;
  ExtraInfo : PDVDSubtitle_Info;
  Text      : String;
begin
  Result  := False;
  SubFile := TUWStringList.Create;
  try
    ExtraInfo := Subtitles.Header;
    if ExtraInfo = NIL then Exit;

    SubFile.Add('{HEAD', False);
    SubFile.Add('DISCID=' + ExtraInfo^.DiskId, False);
    SubFile.Add('DVDTITLE=' + ExtraInfo^.DVDTitle, False);
    SubFile.Add('CODEPAGE=1250', False);
    SubFile.Add('FORMAT=ASCII', False);
    SubFile.Add('LANG=' + ExtraInfo^.Language, False);
    SubFile.Add('TITLE=1', False);
    SubFile.Add('ORIGINAL=ORIGINAL', False);
    SubFile.Add('AUTHOR=' + ExtraInfo^.Author, False);
    SubFile.Add('WEB=' + ExtraInfo^.Web, False);
    SubFile.Add('INFO=' + ExtraInfo^.Info, False);
    SubFile.Add('LICENSE=' + ExtraInfo^.License, False);
    SubFile.Add('}', False);

    for i := FromItem to ToItem do
    begin
      Text := RemoveSWTags(iff(SubtitleMode = smText, Subtitles.Text[i], Subtitles.Translation[i]));

      SubFile.Add('{T ' + TimeToString(Subtitles[i].InitialTime, 'hh:mm:ss:zz'), False);
      SubFile.Add(Text, False);
      SubFile.Add('}', False);
      SubFile.Add('{T ' + TimeToString(Subtitles[i].FinalTime, 'hh:mm:ss:zz'), False);
      SubFile.Add('', False);
      SubFile.Add('}', False);
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

function TUWDVDSubtitle.ToText(const Subtitles: TUWSubtitles): String;
begin
  Result := '';
end;

// -----------------------------------------------------------------------------

end.
