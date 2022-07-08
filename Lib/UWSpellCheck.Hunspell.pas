{*
 *  URUWorks Hunspell API
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

unit UWSpellCheck.Hunspell;

// -----------------------------------------------------------------------------

interface

uses
  SysUtils, Classes, dynlibs;

type

  { TUWHunspell }

  TUWHunspell = class
  private
    hunspell_create    : function(aff_file: PChar; dict_file: PChar): Pointer; cdecl;
    hunspell_destroy   : procedure(spell: Pointer); cdecl;
    hunspell_spell     : function(spell: Pointer; word: PChar): Boolean; cdecl;
    hunspell_suggest   : function(spell: Pointer; var suggestions: PPChar; word: PChar): Integer; cdecl;
    hunspell_free_list : procedure(spell: Pointer; var suggestions: PPChar; suggestLen: Integer); cdecl;
    hunspell_add       : function(spell: Pointer; word: PChar): Integer; cdecl;
    FHandle : TLibHandle;
    FSpell  : Pointer;
  public
    constructor Create(const LibraryName: String = {$IFDEF MSWINDOWS}{$IFDEF WIN32}'libhunspellx86.dll'{$ELSE}'libhunspellx64.dll'{$ENDIF}{$ELSE}'libhunspell.so'{$ENDIF});
    destructor Destroy; override;
    function LoadHunspell(const LibraryName: String): Boolean;
    function Ready: Boolean;
    function LoadDictionary(const aff, dict: String): Boolean;
    procedure UnloadDictionary;
    function Spell(const Text: String): Boolean;
    function Suggest(const Text: String; var Suggests: TStrings): Boolean;
    procedure Add(const Word: String);
  end;

// -----------------------------------------------------------------------------

implementation

// -----------------------------------------------------------------------------

constructor TUWHunspell.Create(const LibraryName: String = {$IFDEF MSWINDOWS}{$IFDEF WIN32}'libhunspellx86.dll'{$ELSE}'libhunspellx64.dll'{$ENDIF}{$ELSE}'libhunspell.so'{$ENDIF});
begin
  inherited Create;

  FHandle := 0;
  FSpell  := NIL;
  LoadHunspell(LibraryName);
end;

// -----------------------------------------------------------------------------

destructor TUWHunspell.Destroy;
begin
  UnloadDictionary;

  if FSpell <> NIL then FSpell := NIL;
  if FHandle <> 0 then FreeLibrary(FHandle);

  inherited Destroy;
end;

// -----------------------------------------------------------------------------

function TUWHunspell.LoadHunspell(const LibraryName: String): Boolean;
begin
  Result := False;
  if (LibraryName = '') or (FHandle <> 0) or not FileExists(LibraryName) then Exit;

  FHandle := LoadLibrary(LibraryName);
  if FHandle <> 0 then
  begin
    Result := True;

    Pointer(hunspell_create) := GetProcAddress(FHandle, 'Hunspell_create');
    if not Assigned(hunspell_create) then Result := False;
    Pointer(hunspell_destroy) := GetProcAddress(FHandle, 'Hunspell_destroy');
    if not Assigned(hunspell_destroy) then Result := False;
    Pointer(hunspell_spell) := GetProcAddress(FHandle, 'Hunspell_spell');
    if not Assigned(hunspell_spell) then Result := False;
    Pointer(hunspell_suggest) := GetProcAddress(FHandle, 'Hunspell_suggest');
    if not Assigned(hunspell_suggest) then Result := False;
    Pointer(hunspell_free_list) := GetProcAddress(FHandle, 'Hunspell_free_list');
    if not Assigned(hunspell_free_list) then Result := False;
    Pointer(hunspell_add) := GetProcAddress(FHandle, 'Hunspell_add');
    if not Assigned(hunspell_add) then Result := False;
  end;
end;

// -----------------------------------------------------------------------------

function TUWHunspell.Ready: Boolean;
begin
  Result := FHandle <> 0;
end;

// -----------------------------------------------------------------------------

function TUWHunspell.LoadDictionary(const aff, dict: String): Boolean;
begin
  Result := False;
  if not Ready or not FileExists(aff) or not FileExists(dict) then Exit;

  if Assigned(hunspell_create) then
    FSpell := hunspell_create(PChar(String(aff)), PChar(String(dict)));

  Result := FSpell <> NIL;
end;

// -----------------------------------------------------------------------------

procedure TUWHunspell.UnloadDictionary;
begin
  if Assigned(FSpell) and Assigned(hunspell_destroy) then
  begin
    hunspell_destroy(FSpell);
    FSpell := NIL;
  end;
end;

// -----------------------------------------------------------------------------

function TUWHunspell.Spell(const Text: String): Boolean;
begin
  if Assigned(FSpell) and Assigned(hunspell_spell) then
    Result := hunspell_spell(FSpell, PChar(String(Text)))
  else
    Result := False;
end;

// -----------------------------------------------------------------------------

function TUWHunspell.Suggest(const Text: String; var Suggests: TStrings): Boolean;
var
  l, i : Integer;
  s    : PPChar;
begin
  if (Suggests = NIL) then Suggests := TStringList.Create;
  Suggests.Clear;

  if Assigned(FSpell) and Assigned(hunspell_suggest) then
  begin
    l := hunspell_suggest(FSpell, s, PChar(String(Text)));
    for i := 1 to Pred(l) do
      Suggests.Add(String(s[i]));

    if Assigned(hunspell_free_list) then hunspell_free_list(FSpell, s, l);
  end;

  Result := Suggests.Count > 0;
end;

// -----------------------------------------------------------------------------

procedure TUWHunspell.Add(const Word: String);
begin
  if Assigned(FSpell) and Assigned(hunspell_add) then
    if Word <> '' then hunspell_add(FSpell, PChar(String(Word)));
end;

// -----------------------------------------------------------------------------

end.
