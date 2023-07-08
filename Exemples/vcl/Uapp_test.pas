unit Uapp_test;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls;

type
  TFormPing = class(TForm)
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormPing: TFormPing;

implementation

uses
  dmfbr.modular,
  app.module,
  ping.route.handler;

{$R *.dfm}

procedure TFormPing.Button1Click(Sender: TObject);
var
  LRouteHandler: TPingRouteHandler;
begin
  LRouteHandler := TPingRouteHandler.Create;
  try
    ShowMessage(LRouteHandler.Ping);
  finally
    LRouteHandler.Free;
  end;
end;

procedure TFormPing.FormCreate(Sender: TObject);
begin
  Modular.Start(TAppModule.Create);
end;

end.