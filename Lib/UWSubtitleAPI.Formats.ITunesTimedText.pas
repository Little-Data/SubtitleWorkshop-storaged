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

unit UWSubtitleAPI.Formats.ITunesTimedText;

// -----------------------------------------------------------------------------

interface

uses
  SysUtils, StrUtils, UWSubtitleAPI, UWSystem.TimeUtils, UWSystem.StrUtils,
  UWSubtitleAPI.Formats, Classes, laz2_XMLRead, laz2_DOM, laz2_XMLWrite;

type

  { TUWITunesTimedText }

  TUWITunesTimedText = class(TUWSubtitleCustomFormat)
  public
    function Name: String; override;
    function Format: TUWSubtitleFormats; override;
    function Extension: String; override;
    function IsTimeBased: Boolean; override;
    function HasStyleSupport: Boolean; override;
    function IsMine(const SubtitleFile: TUWStringList; const Row: Integer): Boolean; override;
    function LoadSubtitle(const SubtitleFile: TUWStringList; const FPS: Single; var Subtitles: TUWSubtitles): Boolean; override;
    function SaveSubtitle(const FileName: String; const FPS: Single; const Encoding: TEncoding; const Subtitles: TUWSubtitles; const SubtitleMode: TSubtitleMode; const FromItem: Integer = -1; const ToItem: Integer = -1): Boolean; override;
    function ToText(const Subtitles: TUWSubtitles): String; override;
  end;

// -----------------------------------------------------------------------------

implementation

uses UWSubtitleAPI.Tags, UWSystem.XmlUtils;

// -----------------------------------------------------------------------------

function TUWITunesTimedText.Name: String;
begin
  Result := IndexToName(Integer(Format));
end;

// -----------------------------------------------------------------------------

function TUWITunesTimedText.Format: TUWSubtitleFormats;
begin
  Result := TUWSubtitleFormats.sfITunesTimedText;
end;

// -----------------------------------------------------------------------------

function TUWITunesTimedText.Extension: String;
begin
  Result := '*.itt';
end;

// -----------------------------------------------------------------------------

function TUWITunesTimedText.IsTimeBased: Boolean;
begin
  Result := True;
end;

// -----------------------------------------------------------------------------

function TUWITunesTimedText.HasStyleSupport: Boolean;
begin
  Result := True;
end;

// -----------------------------------------------------------------------------

function TUWITunesTimedText.IsMine(const SubtitleFile: TUWStringList; const Row: Integer): Boolean;
begin
  if (LowerCase(ExtractFileExt(SubtitleFile.FileName)) = '.itt') and
  SubtitleFile[Row].Contains('<tt xml') then
    Result := True
  else
    Result := False;
end;

// -----------------------------------------------------------------------------

function TUWITunesTimedText.LoadSubtitle(const SubtitleFile: TUWStringList; const FPS: Single; var Subtitles: TUWSubtitles): Boolean;

  function GetTime(const S: String; const aFPS: Single): Integer;
  begin
    if AnsiEndsStr('t', S) then // ticks
      Result := TicksToMSecs(StrToInt64(Copy(S, 0, Length(S)-1)))
    else if AnsiEndsStr('s', S) then // seconds
        Result := StringToTime(Copy(S, 0, Length(S)-1))
    else
      Result := StringToTime(S, False, aFPS);
  end;

var
  XmlDoc      : TXMLDocument;
  Node        : TDOMNode;
  InitialTime : Integer;
  FinalTime   : Integer;
  Text        : String;
  fr          : Single;
begin
  Result := False; // TODO: read styles,...
  XmlDoc := NIL;
  ReadXMLFile(XmlDoc, SubtitleFile.FileName);
  if Assigned(XmlDoc) then
    try
      Node := XMLFindNodeByName(XmlDoc, 'tt');
      if Assigned(Node) and XMLHasAttribute(Node, 'ttp:frameRate') then
        fr := StrToFloatDef(XMLGetAttrValue(Node, 'ttp:frameRate'), 25);

      Node := XMLFindNodeByName(XmlDoc, 'p');
      if Assigned(Node) then
        repeat
          InitialTime := GetTime(Node.Attributes.GetNamedItem('begin').NodeValue, fr);
          FinalTime   := GetTime(Node.Attributes.GetNamedItem('end').NodeValue, fr);
          Text        := ReplaceEnters(Node.TextContent, '<br/>', LineEnding);
          writeln(Node.TextContent);
          Subtitles.Add(InitialTime, FinalTime, HTMLTagsToSW(Text), '', NIL, False);


          Node := Node.NextSibling;
        until (Node = NIL);
    finally
       XmlDoc.Free;
       Result := Subtitles.Count > 0;
    end;
end;

// -----------------------------------------------------------------------------

function TUWITunesTimedText.SaveSubtitle(const FileName: String; const FPS: Single; const Encoding: TEncoding; const Subtitles: TUWSubtitles; const SubtitleMode: TSubtitleMode; const FromItem: Integer = -1; const ToItem: Integer = -1): Boolean;
var
  XmlDoc : TXMLDocument;
  Root, Element, Node, SubNode : TDOMNode;
  i : Integer;
  s : String;
begin
  Result := False;
  XmlDoc := TXMLDocument.Create;
  try
    Root := XmlDoc.CreateElement('tt');
      TDOMElement(Root).SetAttribute('xmlns', 'http://www.w3.org/ns/ttml');
      TDOMElement(Root).SetAttribute('xmlns:ttp', 'http://www.w3.org/ns/ttml#parameter');
      TDOMElement(Root).SetAttribute('ttp:timeBase', 'media');
      TDOMElement(Root).SetAttribute('xmlns:tts', 'http://www.w3.org/ns/ttml#style');
      TDOMElement(Root).SetAttribute('xml:lang', 'en');
      TDOMElement(Root).SetAttribute('xmlns:ttm', 'http://www.w3.org/ns/ttml#metadata');
      TDOMElement(Root).SetAttribute('ttp:timeBase', 'smpte');

      if FPS <= 24 then
        s := '24'
      else if (FPS > 24) and (FPS < 29) then
        s := '25'
      else
        s := '30';

      TDOMElement(Root).SetAttribute('ttp:frameRate', s);

      if (FPS < 24) or ((FPS > 29) and (FPS < 30)) then
        s := '999 1000'
      else
        s := '1 1';

      TDOMElement(Root).SetAttribute('ttp:frameRateMultiplier', s);
      TDOMElement(Root).SetAttribute('ttp:dropMode', 'nonDrop');

      XmlDoc.Appendchild(Root);
    Root := XmlDoc.DocumentElement;

    Element := XmlDoc.CreateElement('head');
      TDOMElement(Element).SetAttribute('xmlns', '');
      Node := XmlDoc.CreateElement('metadata');
      Element.AppendChild(Node);
      SubNode := XmlDoc.CreateElement('ttm:title');
      Node.AppendChild(SubNode);
    Root.AppendChild(Element);
      Node := XmlDoc.CreateElement('styling');
      Element.AppendChild(Node);
      SubNode := XmlDoc.CreateElement('style');
      TDOMElement(SubNode).SetAttribute('id', 'normal');
      TDOMElement(SubNode).SetAttribute('tts:fontStyle', 'normal');
      TDOMElement(SubNode).SetAttribute('tts:fontSize', '100%');
      TDOMElement(SubNode).SetAttribute('tts:fontWeight', 'normal');
      TDOMElement(SubNode).SetAttribute('tts:fontFamily', 'sansSerif');
      TDOMElement(SubNode).SetAttribute('tts:color', 'white');
      Node.AppendChild(SubNode);
    Root.AppendChild(Element);

    Node := XmlDoc.CreateElement('layout');
    Element.AppendChild(Node);
      SubNode := XmlDoc.CreateElement('region');
      TDOMElement(SubNode).SetAttribute('id', 'top');
      TDOMElement(SubNode).SetAttribute('tts:origin', '0% 0%');
      TDOMElement(SubNode).SetAttribute('tts:extent', '100% 15%');
      TDOMElement(SubNode).SetAttribute('tts:textAlign', 'center');
      TDOMElement(SubNode).SetAttribute('tts:displayAlign', 'before');
      Node.AppendChild(SubNode);
      SubNode := XmlDoc.CreateElement('region');
      TDOMElement(SubNode).SetAttribute('id', 'bottom');
      TDOMElement(SubNode).SetAttribute('tts:origin', '0% 85%');
      TDOMElement(SubNode).SetAttribute('tts:extent', '100% 15%');
      TDOMElement(SubNode).SetAttribute('tts:textAlign', 'center');
      TDOMElement(SubNode).SetAttribute('tts:displayAlign', 'after');
      Node.AppendChild(SubNode);
    Root.AppendChild(Element);

    Element := XmlDoc.CreateElement('body');
      TDOMElement(Element).SetAttribute('style', 'normal');
    Root.AppendChild(Element);

    Node := XmlDoc.CreateElement('div');
    Element.AppendChild(Node);

    for i := FromItem to ToItem do
    begin
      Element := XmlDoc.CreateElement('p');
      TDOMElement(Element).SetAttribute('region', iff(Subtitles[i].VAlign > 0, 'top', 'bottom'));
      TDOMElement(Element).SetAttribute('begin', TimeToString(Subtitles.InitialTime[i], 'hh:mm:ss:ff', FPS));
      //TDOMElement(Element).SetAttribute('id', TimeToString(Subtitles.InitialTime[i], 'p' + IntToStr(i)));
      TDOMElement(Element).SetAttribute('end', TimeToString(Subtitles.FinalTime[i], 'hh:mm:ss:ff', FPS));
      SubNode := XmlDoc.CreateTextNode(SWTagsToHTML(ReplaceEnters(iff(SubtitleMode = smText, Subtitles.Text[i], Subtitles.Translation[i]), sLineBreak, '<br/>')));
      Element.AppendChild(SubNode);
      Node.AppendChild(Element);
    end;

    try
      WriteXMLFile(XmlDoc, FileName);
    except
    end;
  finally
    XmlDoc.Free;
  end;
end;

// -----------------------------------------------------------------------------

function TUWITunesTimedText.ToText(const Subtitles: TUWSubtitles): String;
begin
  Result := '';
end;

// -----------------------------------------------------------------------------

end.
