unit ping.controller;

interface

uses
  ping.service;

type
  TPingController = class
  private
    FService: TPingService;
  public
    constructor Create(const AService: TPingService);
    destructor Destroy; override;
    function Ping: string;
  end;

implementation

{ TPingController }

constructor TPingController.Create(const AService: TPingService);
begin
  FService := AService;
end;

destructor TPingController.Destroy;
begin
  FService.Free;
  inherited;
end;

function TPingController.Ping: String;
begin
  Result := FService.Ping;
end;

end.