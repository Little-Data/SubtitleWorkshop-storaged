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

unit UWSubtitleAPI.Formats.GPACTTXT;

// -----------------------------------------------------------------------------

interface

uses
  SysUtils, UWSubtitleAPI, UWSystem.TimeUtils, UWSystem.StrUtils,
  UWSubtitleAPI.Formats, Classes, laz2_XMLRead, laz2_DOM, laz2_XMLWrite;

type

  { TUWGPACTTXT }

  TUWGPACTTXT = class(TUWSubtitleCustomFormat)
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

uses UWSubtitleAPI.ExtraInfo, UWSubtitleAPI.Tags, UWSystem.XmlUtils;

// -----------------------------------------------------------------------------

function TUWGPACTTXT.Name: String;
begin
  Result := IndexToName(Integer(Format));
end;

// -----------------------------------------------------------------------------

function TUWGPACTTXT.Format: TUWSubtitleFormats;
begin
  Result := TUWSubtitleFormats.sfGPAC;
end;

// -----------------------------------------------------------------------------

function TUWGPACTTXT.Extension: String;
begin
  Result := '*.ttxt';
end;

// -----------------------------------------------------------------------------

function TUWGPACTTXT.IsTimeBased: Boolean;
begin
  Result := True;
end;

// -----------------------------------------------------------------------------

function TUWGPACTTXT.HasStyleSupport: Boolean;
begin
  Result := True;
end;

// -----------------------------------------------------------------------------

function TUWGPACTTXT.IsMine(const SubtitleFile: TUWStringList; const Row: Integer): Boolean;
begin
  if (SubtitleFile[Row] = '<!-- GPAC 3GPP Text Stream -->') or
    SubtitleFile[Row].Contains('<TextStream version="1.') then
    Result := True
  else
    Result := False;
end;

// -----------------------------------------------------------------------------

function TUWGPACTTXT.LoadSubtitle(const SubtitleFile: TUWStringList; const FPS: Single; var Subtitles: TUWSubtitles): Boolean;
var
  XmlDoc      : TXMLDocument;
  Node        : TDOMNode;
  InitialTime : Integer;
  FinalTime   : Integer;
  Text        : String;
begin
  Result := False;
  XmlDoc := NIL;
  ReadXMLFile(XmlDoc, SubtitleFile.FileName);
  if Assigned(XmlDoc) then
    try
      Node := XMLFindNodeByName(XmlDoc, 'TextSample');
      if Assigned(Node) then
        repeat
          // First node has InitialTime and Subtitle text
          InitialTime := StringToTime(Node.Attributes.GetNamedItem('sampleTime').NodeValue);
          if XMLHasAttribute(Node, 'text') then
            Text := HTMLTagsToSW(ReplaceEnters(XMLGetAttrValue(Node, 'text'), '<br/>', LineEnding))
          else
            Text := HTMLTagsToSW(ReplaceEnters(Node.TextContent, '<br/>', LineEnding));

          // Next node has FinalTime
          Node := Node.NextSibling;
          if Assigned(Node) then
          begin
            FinalTime := StringToTime(XMLGetAttrValue(Node, 'sampleTime'));
            if XMLHasAttribute(Node, 'text') then Node := Node.PreviousSibling;
          end
          else
            FinalTime := InitialTime + 1000;

          Subtitles.Add(InitialTime, FinalTime, HTMLTagsToSW(Text), '', NIL, False);
          Node := Node.NextSibling;
        until (Node = NIL);
    finally
       XmlDoc.Free;
       Result := Subtitles.Count > 0;
    end;
end;

// -----------------------------------------------------------------------------

function TUWGPACTTXT.SaveSubtitle(const FileName: String; const FPS: Single; const Encoding: TEncoding; const Subtitles: TUWSubtitles; const SubtitleMode: TSubtitleMode; const FromItem: Integer = -1; const ToItem: Integer = -1): Boolean;
var
  XmlDoc : TXMLDocument;
  Root, Element, Node, SubNode : TDOMNode;
  i : Integer;
begin
  Result := False;
  XmlDoc := TXMLDocument.Create;
  try
    XmlDoc.AppendChild(XmlDoc.CreateComment(' GPAC 3GPP Text Stream '));

    Root := XmlDoc.CreateElement('TextStream');
      TDOMElement(Root).SetAttribute('version', '1.1');
      XmlDoc.Appendchild(Root);
    Root := XmlDoc.DocumentElement;

    Element := XmlDoc.CreateElement('TextStreamHeader');
      TDOMElement(Element).SetAttribute('translation_y', '0');
      TDOMElement(Element).SetAttribute('translation_x', '0');
      TDOMElement(Element).SetAttribute('layer', '0');
      TDOMElement(Element).SetAttribute('height', '60');
      TDOMElement(Element).SetAttribute('width', '400');
    Root.AppendChild(Element);

    Node := XmlDoc.CreateElement('TextSampleDescription');
      TDOMElement(Node).SetAttribute('scroll', 'None');
      TDOMElement(Node).SetAttribute('continuousKaraoke', 'no');
      TDOMElement(Node).SetAttribute('fillTextRegion', 'no');
      TDOMElement(Node).SetAttribute('verticalText', 'no');
      TDOMElement(Node).SetAttribute('backColor', '0 0 0 0');
      TDOMElement(Node).SetAttribute('verticalJustification', 'bottom');
      TDOMElement(Node).SetAttribute('horizontalJustification', 'center');
    Element.AppendChild(Node);

    Element := XmlDoc.CreateElement('FontTable');
    Node.AppendChild(Element);

    SubNode := XmlDoc.CreateElement('FontTableEntry');
      TDOMElement(SubNode).SetAttribute('fontID', '1');
      TDOMElement(SubNode).SetAttribute('fontName', 'serif');
    Element.AppendChild(SubNode);

    Element := XmlDoc.CreateElement('TextBox');
      TDOMElement(Element).SetAttribute('right', '400');
      TDOMElement(Element).SetAttribute('bottom', '60');
      TDOMElement(Element).SetAttribute('left', '0');
      TDOMElement(Element).SetAttribute('top', '0');
    Node.AppendChild(Element);

    Element := XmlDoc.CreateElement('Style');
      TDOMElement(Element).SetAttribute('fontID', '1');
      TDOMElement(Element).SetAttribute('color', 'ff ff ff ff');
      TDOMElement(Element).SetAttribute('fontSize', '18');
      TDOMElement(Element).SetAttribute('styles', 'Normal');
    Node.AppendChild(Element);

    for i := FromItem to ToItem do
    begin
      Element := XmlDoc.CreateElement('TextSample');
      TDOMElement(Element).SetAttribute('xml:space', 'preserve');
      TDOMElement(Element).SetAttribute('sampleTime', TimeToString(Subtitles.InitialTime[i], 'hh:mm:ss.zzz'));
      SubNode := XmlDoc.CreateTextNode(SWTagsToHTML(ReplaceEnters(iff(SubtitleMode = smText, Subtitles.Text[i], Subtitles.Translation[i]), sLineBreak, '<br/>')));
      Element.AppendChild(SubNode);
      Root.AppendChild(Element);

      Element := XmlDoc.CreateElement('TextSample');
      TDOMElement(Element).SetAttribute('xml:space', 'preserve');
      TDOMElement(Element).SetAttribute('sampleTime', TimeToString(Subtitles.FinalTime[i], 'hh:mm:ss.zzz'));
      Root.AppendChild(Element);
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

function TUWGPACTTXT.ToText(const Subtitles: TUWSubtitles): String;
begin
  Result := '';
end;

// -----------------------------------------------------------------------------

end.
