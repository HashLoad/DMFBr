unit ping.service;

interface

type
  TPingService = class
  public
    function Ping: string;
  end;

implementation

{ TPingService }

function TPingService.Ping: string;
begin
  Result := 'Pong';
end;

end.