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

unit UWSubtitleAPI.Formats.Cheetah;

// -----------------------------------------------------------------------------

interface

uses
  Classes, SysUtils, UWSubtitleAPI, UWSystem.TimeUtils, UWSubtitleAPI.Formats;

type

  { TUWCheetah }

  TUWCheetah = class(TUWSubtitleCustomFormat)
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

function TUWCheetah.Name: String;
begin
  Result := IndexToName(Integer(Format));
end;

// -----------------------------------------------------------------------------

function TUWCheetah.Format: TUWSubtitleFormats;
begin
  Result := TUWSubtitleFormats.sfCheetah;
end;

// -----------------------------------------------------------------------------

function TUWCheetah.Extension: String;
begin
  Result := '*.asc';
end;

// -----------------------------------------------------------------------------

function TUWCheetah.HasStyleSupport: Boolean;
begin
  Result := False;
end;

// -----------------------------------------------------------------------------

function TUWCheetah.IsMine(const SubtitleFile: TUWStringList; const Row: Integer): Boolean;
begin
  if LowerCase(SubtitleFile[Row]).StartsWith('** caption number') or
     (LowerCase(SubtitleFile[Row]).StartsWith('*t ') and
     (TimeInFormat(Copy(SubtitleFile[Row], 4, 11), 'hh:mm:ss:zz'))) then
     Result := True
   else
     Result := False;
end;

// -----------------------------------------------------------------------------

function TUWCheetah.LoadSubtitle(const SubtitleFile: TUWStringList; const FPS: Single; var Subtitles: TUWSubtitles): Boolean;
var
  i, c        : Integer;
  InitialTime : Integer;
  FinalTime   : Integer;
  Text        : String;
begin
  Result := False;
  try
    for i := SubtitleFile.Count-1 downto 0 do
      if (Pos('*', SubtitleFile[i]) = 1) and (Pos('*t ', LowerCase(SubtitleFile[i])) <> 1) then
        SubtitleFile.Delete(i);

    for i := 0 to SubtitleFile.Count-2 do
    begin
      if (TimeInFormat(Copy(SubtitleFile[i], 4, 11), 'hh:mm:ss:zz')) then
      begin
        c    := 1;
        Text := '';
        while (i+c < (SubtitleFile.Count-1)) and (Pos('*', SubtitleFile[i+c]) <> 1) do
        begin
          if Text <> '' then
            Text := Text + LineEnding + SubtitleFile[i+c]
          else
            Text := SubtitleFile[i+c];

          Inc(c);
        end;

        InitialTime := StringToTime(Copy(SubtitleFile[i], 4, 11));
        FinalTime   := StringToTime(Copy(SubtitleFile[i+c], 4, 11));
        Subtitles.Add(InitialTime, FinalTime, Text, '');
      end;
    end;
  finally
    Result := Subtitles.Count > 0;
  end;
end;

// -----------------------------------------------------------------------------

function TUWCheetah.SaveSubtitle(const FileName: String; const FPS: Single; const Encoding: TEncoding; const Subtitles: TUWSubtitles; const FromItem: Integer = -1; const ToItem: Integer = -1): Boolean;
var
  SubFile : TUWStringList;
  i, SubIndex : Integer;
begin
  Result  := False;
  SubFile := TUWStringList.Create;
  try
    SubFile.Add('*NonDropFrame', False);
    SubFile.Add('*Width 32', False);
    SubFile.Add('', False);
    SubIndex := 1;
    for i := FromItem to ToItem do
    begin
      Subtitles.Text[i] := RemoveSWTags(Subtitles.Text[i]);

      SubFile.Add('** Caption Number '+ IntToStr(SubIndex), False);
      SubFile.Add('*PopOn', False);
      SubFile.Add('*T ' + TimeToString(Subtitles[i].InitialTime, 'hh:mm:ss:zz'), False);
      SubFile.Add('*BottomUp', False);
      SubFile.Add('*Lf01', False);
      SubFile.Add(Subtitles[i].Text, False);
      SubFile.Add('', False);
      Inc(SubIndex);

      SubFile.Add('** Caption Number '+ IntToStr(SubIndex), False);
      SubFile.Add('*PopOn', False);
      SubFile.Add('*T ' + TimeToString(Subtitles[i].FinalTime, 'hh:mm:ss:zz'), False);
      SubFile.Add('*BottomUp', False);
      SubFile.Add('*Lf01', False);
      SubFile.Add('', False);
      SubFile.Add('', False);
      Inc(SubIndex);
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

function TUWCheetah.ToText(const Subtitles: TUWSubtitles): String;
begin
  Result := '';
end;

// -----------------------------------------------------------------------------

end.
