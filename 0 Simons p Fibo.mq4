//+------------------------------------------------------------------+
//|                                               0 Simons Fibo .mq4 |
//|                             Copyright 2017-2018, SzymonMarek.com |
//|                                      https://www.SzymonMarek.com |
//+------------------------------------------------------------------+
//w planie hide/show dla support resistance lines

//20190525 doadłem idnywidualne hide/show dla geometrii. fajniusie. udoskonaliłem hide/show dla linii trendu.

///20190105 0559  i wcześniej tutaj ogarniam wszystko po nowemu w tym 2019 roku i jest słupek i jest piknie

//20180901 drobne modyfikacje open price, elliott

//20180721 proba dodania opisow do geometrii przynajmniej tych bazowych

//20180618 dodałem linie trendu dziurkovane

//20180609 dodalem guziki do ogladania wykresow, long term i short term
//         dodalem mozliwosc zmniejszania, zwiekszania okna oraz ustawienia autoscroll i shift

//20180608 dodalem zmiane naroznika i zmienilem na ang zeby w szwajcarii tez chodzilo

//20180518 dodaję cenę otwarcia z większymi roszerzeniami,
//         dodaję zliczanie słupków w jednym kolorze

//--- 20180509 dadaję zliczanie słupków w tym samym kolorze
// -- lepsze ustawienie geom, zeby były na środku wykresu

//20180501  - zmiana rodzaju wykresu również na wierzchu, separatory, uporządkowanie kolejności guzików

//20180426  - dodaję możliwość przesuwania panelu na wykresie
//          - kilka dni temu dodałem zaznaczanie użytych i aktywnych geometrii

//20180129  dodaję funkcję kasowania linii trendu (wszystkich na wykresie)
//          dodaję więcej RR i więcej 
//          dozrobienia nic nie gotowe

//20170926  pozostawiam tylko geometrie z guzikami i nic więcej
//20170508 dodałem zmianę rodzaju wykresów i możliwość dodawania linii seperatorów okresów

//ogólnie zmieniam koncepcję do patrzenia na wykres przez pryzmat wyższych skal
//trend definiuje m30 lub i H1

#property copyright "Copyright 2017-2019, SzymonMarek.com"
#property link      "https://www.SzymonMarek.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
#include "Include_S.mqh"
//+------------------------------------------------------------------+
enum ENUMs_Chart_Type
{
   chart_Bars,
   chart_Candles,
   chart_Lines
};
enum ENUMs_Line_Width
{
   width_1 = 1,
   width_2,
   width_3,
   width_4,
   width_5
};
enum ENUMs_SR_Line
{
   line_SR_C,
   line_SR_S,
   line_SR_R
};

//--- ustawienia wyświetlania
extern string           s2                            = "+--- Ustaienia Linii godziny otarcia ---+";//---
extern bool             blnE_OP_Line                  = false;
extern int              intE_Godz                     = 8;
extern int              intE_Min                      = 00;
extern string           s4                            = "+--- ustawienia S/R Lines ---+";//---
extern ENUMs_Line_Width intE_SR_Width                 = width_2;
extern string           s5                            = "+--- Auto Skale---+";//---
extern int              intE_Scale_LT                 = 2;
extern int              intE_Scale_ST                 = 5;
extern int              intE_OP_Line_Shift            = 10;
extern bool             blnE_NewBar_Alert             = false;
extern string           s6                            = "+--- Czy   ---+";//---
extern bool             blnE_ElliotAndChartManagement = true;
//extern bool             blnE_EllioTTonRSI             = false;
//---

//róg jeden i niezmienny
ENUM_BASE_CORNER        extG_CORNER = CORNER_LEFT_LOWER;
//--- ustawienia geomeetrii
color             clrE_BS_Color     = clrDarkViolet;
ENUM_LINE_STYLE   inp_BS_Style      = STYLE_DOT;
color             clrE_LL_Color     = clrOrchid;
ENUM_LINE_STYLE   inp_LL_Style      = STYLE_DOT;
color             clrE_LL1_Color    = clrSlateGray;
ENUM_LINE_STYLE   stlE_LL1_Style    = STYLE_DOT;
color             clrE_RR_Color     = clrRed;
ENUM_LINE_STYLE   inp_RR_Style      = STYLE_DOT;
color             clrE_RR1_Color    = clrCrimson;
ENUM_LINE_STYLE   stlE_RR1_Style    = STYLE_DOT;
ENUMs_Line_Width  intE_RR1_Width    = width_1;
color             clrE_CA_Color     = clrAqua;
ENUM_LINE_STYLE   inp_CA_Style      = STYLE_DOT;
color             clrE_W5_Color     = clrSilver;
ENUM_LINE_STYLE   inp_W5_Style      = STYLE_DOT;
color             clrE_OP_Color     = clrSteelBlue;
ENUM_LINE_STYLE   stlE_OP_Style     = STYLE_DOT;
color             clrE_W15_Color    = clrDarkTurquoise;
ENUM_LINE_STYLE   stlE_W15_Style    = STYLE_DOT;
color             clrE_W11_Color    = clrLime;
ENUM_LINE_STYLE   stlE_W11_Style    = STYLE_DOT;
int               intG_Step_V       = 149;
int               intG_Step_H       = 115;
///---///---///---///--- rozwojowe
//magiczny guzik ukrywania guzików(oprócz siebie)
string strG_HideAllButtons    = "Meta HiABu";
string strG_Support_ResistanceAsRectangleInBlueWithDescription;
///---///---///---///---
//guziki do zmiany wykresu
string strG_Chart_Candles     = "Chart_Candles";
string strG_Chart_Bars        = "Chart_Bars";
string strG_Chart_Line        = "Chart_Line";
string strG_Chart_SepLines    = "Chrt_Sep";
string strG_Chart_Scale_Up    = "Scale_Up";
string strG_Chart_Scale_Dn    = "Scale_Dn";
string strG_Chart_Scale_ST    = "Scale_ST"; //short term
string strG_Chart_Scale_LT    = "Scale_LT"; //long term
string strG_Chart_Shift       = "Chart Shift";
string strG_Chart_AScroll     = "Chart AScroll";

//guzik elliott
string strG_Elliott           = "Add_Elliott";

//guziki
string strG_BS_Button_Nazwa   = "BS",  strG_BSc_Button_Nazwa   = "BSc",  strG_BSh_Button_Nazwa   = "BSh"; int intG_BS_x, intG_BS_y, intG_BSc_x, intG_BSc_y;
string strG_LL_Button_Nazwa   = "LL",  strG_LLc_Button_Nazwa   = "LLc",  strG_LLh_Button_Nazwa   = "LLh"; int intG_LL_x, intG_LL_y, intG_LLc_x, intG_LLc_y;
string strG_RR_Button_Nazwa   = "RR",  strG_RRc_Button_Nazwa   = "RRc",  strG_RRh_Button_Nazwa   = "RRh"; int intG_RR_x, intG_RR_y, intG_RRc_x, intG_RRc_y;
string strG_CA_Button_Nazwa   = "CA",  strG_CAc_Button_Nazwa   = "CAc",  strG_CAh_Button_Nazwa   = "CAh"; int intG_CA_x, intG_CA_y, intG_CAc_x, intG_CAc_y;
string strG_W5_Button_Nazwa   = "W5",  strG_W5c_Button_Nazwa   = "W5c",  strG_W5h_Button_Nazwa   = "W5h"; int intG_W5_x, intG_W5_y, intG_W5c_x, intG_W5c_y;

string strG_LL1_Button_Nazwa   = "LL1",  strG_LL1c_Button_Nazwa   = "LL1c",  strG_LL1h_Button_Nazwa   = "LL1h"; int intG_LL1_x, intG_LL1_y, intG_LL1c_x, intG_LL1c_y;
string strG_RR1_Button_Nazwa   = "RR1",  strG_RR1c_Button_Nazwa   = "RR1c",  strG_RR1h_Button_Nazwa   = "RR1h"; int intG_RR1_x, intG_RR1_y, intG_RR1c_x, intG_RR1c_y;
string strG_W15_Button_Nazwa   = "W15",  strG_W15c_Button_Nazwa   = "W15c",  strG_W15h_Button_Nazwa   = "W15h"; int intG_W15_x, intG_W15_y, intG_W15c_x, intG_W15c_y;
string strG_W11_Button_Nazwa   = "W11",  strG_W11c_Button_Nazwa   = "W11c",  strG_W11h_Button_Nazwa   = "W11h"; int intG_W11_x, intG_W11_y, intG_W11c_x, intG_W11c_y;

string strG_OP_Button_Nazwa   = "OpPr",strG_OPc_Button_Nazwa = "OpPrc"; int intG_OP_x, intG_OP_y, intG_OPc_x, intG_OPc_y;
string                                 strG_OPL_Button_Nazwa = "OpPrL"; int intG_OPl_x, intG_OPl_y; //open price line

string strG_DA_Button_Nazwa   = "Kasuj";                                int intG_KA_x, intG_KA_y;
string strG_HA_Button_Nazwa   = "Hide All";                             int intG_HA_x, intG_HA_y;


//guziki do przesuwania panelu na wykresie
string strG_Arrow_Up = "A_UP"; int intG_A_UP_x, intG_A_UP_y;
string strG_Arrow_Dn = "A_DN"; int intG_A_DN_x, intG_A_DN_y;
//string strG_Arrow_Lf = "A_LF"; int intG_A_LF_x, intG_A_LF_y;
//string strG_Arrow_Rt = "A_RT"; int intG_A_RT_x, intG_A_RT_y;

//string strG_Arrow_C_UpRt   = "A_C_UpRt"; int intG_A_C_UpRt_x, intG_A_C_UpRt_y;
//string strG_Arrow_C_Lf_Up  = "A_C_UpLt"; int intG_A_C_UpLt_x, intG_A_C_UpLt_y;
//string strG_Arrow_C_DnRt   = "A_C_DnRt"; int intG_A_C_DnRt_x, intG_A_C_DnRt_y;
//string strG_Arrow_C_Lf_Dn  = "A_C_DnLt"; int intG_A_C_DnLt_x, intG_A_C_DnLt_y;

//string strG_Arrow_C_Rt_Dn = "A_B_"; int intG_A_B__x, intG_A_B__y; //Base powrót do ustawien początkowych

//string strG_Label_BarCount = "BarCount"; //zlicza ostatnie słupki z korpusem w tym samym kolorze
//string strG_Label_Change   = "DayChange"; //20180817 - ile pkt ruch dzisiaj od open do teraz

//string strG_Shade_BarCount = "Shade Bar Count";//tło na czarno
//string strG_Shade_Change   = "Shade Change";

//string strG_Shade_Viper    = "Shade Viper";//tło na czarno
//string strG_Label_Viper    = "Label Viper";

////tło na czarno

//dodatek z 31/06/2018 nazwa wykresu
string strG_ChartName         = "chart name";
string strG_Shade_Buttons     = "Shade Fibo Buttons";
string strG_Shade_Title       = "Shade Fibo Title";
//nazwy obiektów geometrycznych
string strG_LL_Fibo_Nazwa     = "Last Leg";
string strG_BS_Fibo_Nazwa     = "Big Swing";
string strG_RR_Fibo_Nazwa     = "Ref Ret";
string strG_CA_Fibo_Nazwa     = "CvsA";
string strG_W5_Fibo_Nazwa     = "5vs4";
string strG_OP_Fibo_Nazwa     = "OpenPrice";
string strG_TM_Fibo_Nazwa     = "Time Cycle";

string strG_LL1_Fibo_Nazwa    = "Last Leg 1";
string strG_RR1_Fibo_Nazwa    = "Ref Ret 1";
string strG_W15_Fibo_Nazwa    = "W 13-5";
string strG_W11_Fibo_Nazwa    = "W 1 -5";

////nazwy opisów geometrii
//string strG_BS_Fibo_Letters   = "BS_";
//string strG_LL_Fibo_Letters   = "LL_";
//string strG_RR_Fibo_Letters   = "RR_0";
//string strG_CA_Fibo_Letters   = "C:A_";
//string strG_W5_Fibo_Letters   = "W5_";
//string strG_LL1_Fibo_Letters  = "LL_1";
//string strG_RR1_Fibo_Letters  = "RR_1";
//string strG_W15_Fibo_Letters  = "W15_";
//string strG_OP_Fibo_Letters   = "OP_";
//string strG_W11_Fibo_Letters  = "W1_"; 

//super ogólnie
long  lngG_ID        = ChartID();   //chart ID
int   intG_Bars      = 0;
int   intG_Przelot   = 0;
ENUM_TIMEFRAMES enmG_TF = Period();

// linia ceny open
string   strG_OP_Line, strG_Mx_Line, strG_Mn_Line, strG_Range_Line, strG_HA_Close;
//datetime dttG_OP_Time;
//double   dblG_OP_Val;
//int      intG_OP_I_TTF;


//kolekcja przycisków do szybszego zarządzania tym
string col_Buttons[100];
int    col_X[100];
int    col_Y[100];
string col_Fibo[26];
color  col_Fibo_Colors[26];
string col_Letters[26];

//dodatek z 13/06
string strG_SR_R_Button_Name  = "R", strG_SR_R_Line = "Resistance Line ";
string strG_SR_S_Button_Name  = "S", strG_SR_S_Line = "Support Line ";
string strG_SR_D_Button_Name  = "D"; 
//dodatek z 18/06
string strG_TL_1_Button_Name = "T1", strG_TL_2_Button_Name = "T2",strG_TL_d_Button_Name = "Td";
string strG_TL_Hide_Show_Button_Name = "TL_HS";
//dodatek z 7/08
string col_fale_RomanBracekt[19]    = {"(i)","(ii)","(iii)","(iv)","(v)","(iv/a)","(v/b)","(i/a)","(ii/b)","(iii/c)","(a)","(b)","(c)","(d)","(e)","(w)","(x)","(y)","(z)"};
string col_fale_Roman[23]           = {"i","ii","iii","iv","v","i/a","ii/b","iii/c","iv/d","v/e","a","b","c","d","e","w","x","y","z","II-emma","IV-emma","II-wanda","iv-wanda"};
string col_fale_Small[22]           = {"1","2","3","4","5",">>5","6","7","1/a","2/b","3/c","4/d","5/e","a","b","c","d","e","w","x","y","z"};
string col_fale_Capital[17]         = {"1","2","3","4","5","1/A","2/B","3/C","A","B","C","D","E","W","X","Y","Z"};
string col_fale_CapitalBracket[17]  = {"(1)","(2)","(3)","(4)","(5)","(1/A)","(2/B)","(3/C)","(A)","(B)","(C)","(D)","(E)","(W)","(X)","(Y)","(Z)"};
string col_fale_ALT[19]             = {"alt1","alt2","alt3","alt4","alt5","RR","LL","BS","altA","altB","altC","altD","altE","altW","altX","altY","altZ","UP","DOWN"};

// daily max min
double dblG_Daily_Mx;
double dblG_Daily_Mn;
string strG_Daily_Range; 
string strG_BasePrice,strG_BasePriceTxt;// średnia z Open-High-Low
string strG_GlutPrice,strG_GlutPriceTxt;// średnia z High-Low_Close

////ukrywanie linii trendu
//string            col_TL_Nazwy[100];
//color             col_TL_Kolory[100];
//ENUM_LINE_STYLE   col_TL_Style[100];
//int               col_TL_Grubosci[100];

////eksperymenty
//double dblG_ChartShiftSize=0.0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //---+ ustawienia wykresu
   ChartSetInteger(lngG_ID,CHART_SHOW_GRID,0,false);               //wyłacza siatkę
   ChartSetInteger(lngG_ID,CHART_FOREGROUND,0,false);              //wykres na drugim planie
   
   if       (ChartGetInteger(lngG_ID,CHART_COLOR_BACKGROUND) == clrBlack)
   {
      ChartSetInteger(lngG_ID,CHART_COLOR_CHART_UP,clrWhite);         //kolory słupków
      ChartSetInteger(lngG_ID,CHART_COLOR_CHART_DOWN,clrWhite);
      ChartSetInteger(lngG_ID,CHART_COLOR_CHART_LINE,clrWhite);
      ChartSetInteger(lngG_ID,CHART_COLOR_CANDLE_BULL,clrWhite);
      ChartSetInteger(lngG_ID,CHART_COLOR_CANDLE_BEAR,clrBlack);
      ChartSetInteger(lngG_ID,CHART_SHOW_OBJECT_DESCR,0,true);
   }
   else if (ChartGetInteger(lngG_ID,CHART_COLOR_BACKGROUND) == clrWhite)
   {
      ChartSetInteger(lngG_ID,CHART_COLOR_CHART_UP,clrBlack);         //kolory słupków
      ChartSetInteger(lngG_ID,CHART_COLOR_CHART_DOWN,clrBlack);
      ChartSetInteger(lngG_ID,CHART_COLOR_CHART_LINE,clrBlack);
      ChartSetInteger(lngG_ID,CHART_COLOR_CANDLE_BULL,clrWhite);
      ChartSetInteger(lngG_ID,CHART_COLOR_CANDLE_BEAR,clrBlack);
      ChartSetInteger(lngG_ID,CHART_SHOW_OBJECT_DESCR,0,true);
   }
   
   
   //ChartSetInteger(lngG_ID,CHART_HEIGHT_IN_PIXELS,1,140);
   //ChartSetInteger(lngG_ID,CHART_HEIGHT_IN_PIXELS,2,140);
   //ChartSetInteger(lngG_ID,CHART_HEIGHT_IN_PIXELS,3,200);   
   
   
   //
   show_ButtonsOnScreen_Fibo();
   
   //kontrola stanów pasków, czy już są geometrie
   check_IfObjectCreated(strG_BS_Fibo_Nazwa, strG_BS_Button_Nazwa);
   check_IfObjectCreated(strG_LL_Fibo_Nazwa, strG_LL_Button_Nazwa);   
   check_IfObjectCreated(strG_RR_Fibo_Nazwa, strG_RR_Button_Nazwa);
   check_IfObjectCreated(strG_CA_Fibo_Nazwa, strG_CA_Button_Nazwa);
   check_IfObjectCreated(strG_W5_Fibo_Nazwa, strG_W5_Button_Nazwa);   
   check_IfObjectCreated(strG_LL1_Fibo_Nazwa, strG_LL1_Button_Nazwa);
   check_IfObjectCreated(strG_RR1_Fibo_Nazwa, strG_RR1_Button_Nazwa);
   check_IfObjectCreated(strG_W15_Fibo_Nazwa, strG_W15_Button_Nazwa);   

   //
   fill_Buttons_Collection();   //wczytanie kolekcji guzików
   fill_Fibo_Collection();      //wczytanie kolekcji nazw geometrii
   fill_Fibo_Colors();          //wczytanie kolekcji kolorów
   //fill_Fibo_Letters();         //opisy 200180721

   //
   //read_Objects_Base_Position_XY();
   
   //DO LINIi OTWARCIA
   delete_OP_Line();
   strG_OP_Line = name_OP_Line();
   strG_Mx_Line = name_Mx_Line();
   strG_Mn_Line = name_Mn_Line();
   strG_Range_Line = "Range Line" + translate_TF(enmG_TF);
   strG_HA_Close = "HAshi Line";

   dblG_Daily_Mx        = -1;
   dblG_Daily_Mn        = -1;
   strG_Daily_Range     = "Range"+Symbol();
   strG_BasePrice       = "OHL"+Symbol();
   strG_BasePriceTxt    = "OHL_Txt"+Symbol();
   strG_GlutPrice       = "HLC"+Symbol();
   strG_GlutPriceTxt    = "HLC_Txt"+Symbol();

   //Alert("RYsuję OPLIne z Innit",Period());
   draw_OP_Line();
   
   if(Period()<=PERIOD_H4)
   {
      if(blnE_OP_Line)  ObjectSetInteger(ChartID(),strG_OPL_Button_Nazwa,OBJPROP_STATE,blnE_OP_Line);          //ustavia guzik
   }
   else
   {
      ObjectSetInteger(ChartID(),strG_OPL_Button_Nazwa,OBJPROP_STATE,false);
   }
   
   //hide_TL();

   //---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//+ buttons 
//+------------------------------------------------------------------+
bool show_ButtonsOnScreen_Fibo()
{
   color clrL_Cancel = clrCrimson;
   color clrL_Base = clrNavy;

   int intL_X = intU_X;
   int i1= 3*1, i2= i1*2, i3= i1*3, i4= i1*4, i5 = i1*5, i6= i1*6, i7 = i1*7, i8 = i1*8, i9 = i1*9, i10 = i1*10, i11 = i1*11, i12 = i1*12;   
   int intL_Y = intU_Y+13*2+i1; //13*2+i1 to margines dla guzikow oscy
   ENUM_BASE_CORNER enmL_Corner = CORNER_LEFT_LOWER;
   string strL_ChartDesc = Symbol() + " " + translate_TF(enmG_TF);   
   int intL_StringLen = StringLen(strL_ChartDesc)*13+6; 
   //paski tła
   color clrL_Shade = clrL_Base;//ChartGetInteger(ChartID(),CHART_COLOR_BACKGROUND); //cień w kolorze tła
   //
   int intL_Shade_X_pos  = intL_X;
   int intL_Shade_Y_pos  = intL_Y+18*14+14*6+i12;
   int intL_Shade_width  = 48;
   int intL_Shade_haight = 18*14+14*6+i12;

   if(!blnE_ElliotAndChartManagement)
   {
      intL_Shade_X_pos = intL_X;
      intL_Shade_Y_pos = intL_Y+18*13+14*3+i9;
      intL_Shade_width = 48;
      intL_Shade_haight =18*13+14*3+i9;
   }
   
   create_RectLabel (ChartID(),strG_Shade_Buttons,0,intL_Shade_X_pos,intL_Shade_Y_pos,intL_Shade_width,intL_Shade_haight,clrL_Shade,1,enmL_Corner);
   //chart name

   ObjectDelete(strG_Shade_Title);ObjectDelete(strG_ChartName);
   if(!find_Object(strG_Shade_Title))  create_RectLabel (ChartID(),strG_Shade_Title,0,intL_X+16*3+6,28,intL_StringLen,25,clrL_Base,1,CORNER_LEFT_UPPER);
   else {ObjectSetInteger(lngG_ID,strG_Shade_Title,OBJPROP_XSIZE,intL_StringLen);}//Alert("Objekt ", strG_Shade_Title," już istnieje"); 
   if(!find_Object(strG_ChartName))    create_Label (lngG_ID,strG_ChartName, 0,intL_X+16*3+6,51, CORNER_LEFT_UPPER,strL_ChartDesc,"Century Gothic",16,clrWhite);
   else ObjectSetString(lngG_ID,strG_ChartName,OBJPROP_TEXT,strL_ChartDesc);
   //buttony
   int intL_del_w = 13;
   
   if(blnE_ElliotAndChartManagement)
   {
      //ODSTĘPY
      //zarządzanie ekranem c.d.
      create_Button(lngG_ID,strG_Chart_AScroll,    0, intL_X,     intL_Y+18*14+14*6+i12,16,     14,enmL_Corner,"R","Arial",8,clrBlack,clrSilver);
      create_Button(lngG_ID,strG_Chart_Shift,      0, intL_X+16,  intL_Y+18*14+14*6+i12,16,     14,enmL_Corner,"M","Arial",8,clrBlack,clrSilver);
      create_Button(lngG_ID,strG_Chart_SepLines,   0, intL_X+32,  intL_Y+18*14+14*6+i12,16,     14,enmL_Corner,"S","Arial",8,clrBlack,clrSilver);
      //rodzaje wykresów
      create_Button(lngG_ID,strG_Chart_Bars,       0, intL_X+16*0,intL_Y+18*14+14*5+i11,16,     18,enmL_Corner,"B","Arial",8,clrBlack,clrGold);
      create_Button(lngG_ID,strG_Chart_Candles,    0, intL_X+16*1,intL_Y+18*14+14*5+i11,16,     18,enmL_Corner,"C","Arial",8,clrBlack,clrGold);
      create_Button(lngG_ID,strG_Chart_Line,       0, intL_X+16*2,intL_Y+18*14+14*5+i11,16,     18,enmL_Corner,"L","Arial",8,clrBlack,clrGold);   
      //ELLIOTT + arrows
      create_Button(lngG_ID,strG_Elliott,          0, intL_X+14,  intL_Y+18*13+14*5+i10,20,     28,enmL_Corner,"E","Arial Black",10,clrL_Base,clrOrange);
      create_Button(lngG_ID,strG_Arrow_Up,         0, intL_X,     intL_Y+18*13+14*5+i10,14,     28,enmL_Corner,"^","Arial",8,clrL_Base,clrPowderBlue);
      create_Button(lngG_ID,strG_Arrow_Dn,         0, intL_X+34,  intL_Y+18*13+14*5+i10,14,     28,enmL_Corner,"v","Arial",8,clrL_Base,clrPowderBlue);
   }
   //*****SR Lines*****
   create_Button(lngG_ID,strG_SR_S_Button_Name,0, intL_X+16*0, intL_Y+18*13+14*3+i9,16,      14,enmL_Corner,"S","Arial",8,clrL_Base,clrLime);
   create_Button(lngG_ID,strG_SR_R_Button_Name,0, intL_X+16*1, intL_Y+18*13+14*3+i9,16,      14,enmL_Corner,"R","Arial",8,clrL_Base,clrRed);
   create_Button(lngG_ID,strG_SR_D_Button_Name,0, intL_X+16*2, intL_Y+18*13+14*3+i9,16,      14,enmL_Corner,"d","Arial",8,clrL_Cancel);
   
   //***** trend lines ***** (18/06)
   create_Button(lngG_ID,strG_TL_1_Button_Name,          0, intL_X+16*0, intL_Y+18*13+14*2+i8,16,      14,enmL_Corner,"D","Arial",8,clrL_Base,clrGold);
   create_Button(lngG_ID,strG_TL_2_Button_Name,          0, intL_X+16*1, intL_Y+18*13+14*2+i8,16,      14,enmL_Corner,"U","Arial",8,clrL_Base,clrGold);
   create_Button(lngG_ID,strG_TL_d_Button_Name,          0, intL_X+16*2, intL_Y+18*13+14*2+i8,16,      14,enmL_Corner,"d","Arial",8,clrL_Cancel);
   create_Button(lngG_ID,strG_TL_Hide_Show_Button_Name,  0, intL_X+16*3, intL_Y+18*13+14*2+i8,16,      14,enmL_Corner,"h","Arial Black",8,clrBlack);

   //zarządzanie ekranem
   create_Button(lngG_ID,strG_Chart_Scale_LT,   0, intL_X,     intL_Y+18*13+14*1+i7,24,      18,enmL_Corner,"LT","Arial",8,clrBlack,clrBrown);
   create_Button(lngG_ID,strG_Chart_Scale_ST,   0, intL_X+24,  intL_Y+18*13+14*1+i7,24,      18,enmL_Corner,"ST","Arial",8,clrBlack,clrGreen);
   create_Button(lngG_ID,strG_Chart_Scale_Dn,   0, intL_X,     intL_Y+18*12+14*1+i6,24,      14,enmL_Corner,"-", "Arial",8,clrBlack,clrRed);
   create_Button(lngG_ID,strG_Chart_Scale_Up,   0, intL_X+24,  intL_Y+18*12+14*1+i6,24,      14,enmL_Corner,"+", "Arial",8,clrBlack,clrLime);
   //kasuj wszystko - delete all
   create_Button(lngG_ID,strG_DA_Button_Nazwa,  0, intL_X,     intL_Y+18*12+i5,  48,         18,enmL_Corner,"Delete All","Arial",8,clrL_Cancel);
   //geometrie RR
   create_Button(lngG_ID,strG_RRh_Button_Nazwa, 0,intL_X,      intL_Y+18*11+i4,  12,         18,enmL_Corner,"h","Arial Black",8,clrBlack);
   create_Button(lngG_ID,strG_RR_Button_Nazwa,  0,intL_X+12,   intL_Y+18*11+i4,  23,         18,enmL_Corner,"RR","Arial",8,clrL_Base);
   create_Button(lngG_ID,strG_RRc_Button_Nazwa, 0,intL_X+35,   intL_Y+18*11+i4,  intL_del_w, 18,enmL_Corner,"d","Arial",8,clrL_Cancel);
   //RR1
   create_Button(lngG_ID,strG_RR1h_Button_Nazwa,0,intL_X,      intL_Y+18*10+i4,  12,         18,enmL_Corner,"h","Arial Black",8,clrBlack);
   create_Button(lngG_ID,strG_RR1_Button_Nazwa, 0,intL_X+12,   intL_Y+18*10+i4,  23,         18,enmL_Corner,"RR1","Arial",8,clrL_Base);
   create_Button(lngG_ID,strG_RR1c_Button_Nazwa,0,intL_X+35,   intL_Y+18*10+i4,  intL_del_w, 18,enmL_Corner,"d","Arial",8,clrL_Cancel);   
   //LL
   create_Button(lngG_ID,strG_LLh_Button_Nazwa, 0,intL_X,      intL_Y+18*09+i4,  12,         18,enmL_Corner,"h","Arial Black",8,clrBlack);
   create_Button(lngG_ID,strG_LL_Button_Nazwa,  0,intL_X+12,   intL_Y+18*09+i4,  23,         18,enmL_Corner,"LL","Arial",8,clrL_Base);
   create_Button(lngG_ID,strG_LLc_Button_Nazwa, 0,intL_X+35,   intL_Y+18*09+i4,  intL_del_w, 18,enmL_Corner,"d","Arial",8,clrL_Cancel);
   //LL1
   create_Button(lngG_ID,strG_LL1h_Button_Nazwa,0,intL_X,      intL_Y+18*08+i4,  12,         18,enmL_Corner,"h","Arial Black",8,clrBlack);   
   create_Button(lngG_ID,strG_LL1_Button_Nazwa, 0,intL_X+12,   intL_Y+18*08+i4,  23,         18,enmL_Corner,"LL1","Arial",8,clrL_Base);
   create_Button(lngG_ID,strG_LL1c_Button_Nazwa,0,intL_X+35,   intL_Y+18*08+i4,  intL_del_w, 18,enmL_Corner,"d","Arial",8,clrL_Cancel);
   //W5
   create_Button(lngG_ID,strG_W5h_Button_Nazwa, 0,intL_X,      intL_Y+18*07+i4,  12,         18,enmL_Corner,"h","Arial Black",8,clrBlack);   
   create_Button(lngG_ID,strG_W5_Button_Nazwa,  0,intL_X+12,   intL_Y+18*07+i4,  23,         18,enmL_Corner,"w5","Arial",8,clrL_Base);
   create_Button(lngG_ID,strG_W5c_Button_Nazwa, 0,intL_X+35,   intL_Y+18*07+i4,  intL_del_w, 18,enmL_Corner,"d","Arial",8,clrL_Cancel);
   // c.d.0 - C:A
   create_Button(lngG_ID,strG_CAh_Button_Nazwa,0,intL_X,       intL_Y+18*06+i3,  12,         18,enmL_Corner,"h","Arial Black",8,clrBlack);   
   create_Button(lngG_ID,strG_CA_Button_Nazwa,  0,intL_X+12,   intL_Y+18*06+i3,  23,         18,enmL_Corner,"C:A","Arial",8,clrL_Base);
   create_Button(lngG_ID,strG_CAc_Button_Nazwa, 0,intL_X+35,   intL_Y+18*06+i3,  intL_del_w, 18,enmL_Corner,"d","Arial",8,clrL_Cancel);
   //W1:5
   create_Button(lngG_ID,strG_W15h_Button_Nazwa,0,intL_X,      intL_Y+18*05+i3,  12,         18,enmL_Corner,"h","Arial Black",8,clrBlack);   
   create_Button(lngG_ID,strG_W15_Button_Nazwa, 0,intL_X+12,   intL_Y+18*05+i3,  23,         18,enmL_Corner,"135","Arial",8,clrL_Base);
   create_Button(lngG_ID,strG_W15c_Button_Nazwa,0,intL_X+35,   intL_Y+18*05+i3,  intL_del_w, 18,enmL_Corner,"d","Arial",8,clrL_Cancel);
   //c.d. - BS
   create_Button(lngG_ID,strG_BSh_Button_Nazwa, 0,intL_X,      intL_Y+18*04+i2,  12,         18,enmL_Corner,"h","Arial Black",8,clrBlack);
   create_Button(lngG_ID,strG_BS_Button_Nazwa,  0,intL_X+12,   intL_Y+18*04+i2,  23,         18,enmL_Corner,"BS","Arial",8,clrL_Base);
   create_Button(lngG_ID,strG_BSc_Button_Nazwa, 0,intL_X+35,   intL_Y+18*04+i2,  intL_del_w, 18,enmL_Corner,"d","Arial",8,clrL_Cancel);   
   //W11
   create_Button(lngG_ID,strG_W11h_Button_Nazwa,0,intL_X,      intL_Y+18*03+i2,  12,         18,enmL_Corner,"h","Arial Black",8,clrBlack);   
   create_Button(lngG_ID,strG_W11_Button_Nazwa, 0,intL_X+12,   intL_Y+18*03+i2,  23,         18,enmL_Corner,"1:5","Arial",8,clrL_Base);
   create_Button(lngG_ID,strG_W11c_Button_Nazwa,0,intL_X+35,   intL_Y+18*03+i2,  intL_del_w, 18,enmL_Corner,"d","Arial",8,clrL_Cancel);   
   //*****cena otwarcia*****
   create_Button(lngG_ID,strG_OP_Button_Nazwa,  0, intL_X,     intL_Y+18*02+i1,  20,         18,enmL_Corner,"OP","Arial",8,clrL_Base);
   create_Button(lngG_ID,strG_OPc_Button_Nazwa, 0, intL_X+20,  intL_Y+18*02+i1,  13,         18,enmL_Corner,"d","Arial",8,clrL_Cancel);
   create_Button(lngG_ID,strG_OPL_Button_Nazwa, 0, intL_X+33,  intL_Y+18*02+i1,  15,         18,enmL_Corner,"O","Arial",8,clrBlack,clrSilver);   
   //ukrywaj geometrie
   create_Button(lngG_ID,strG_HA_Button_Nazwa,  0, intL_X,     intL_Y+18*01,     48,         18,enmL_Corner,"Hide","Arial Black",8,clrBlack);
   //
   check_BarsAndCandles();
         
   return true;
}
//+------------------------------------------------------------------+
bool find_Object(string head_Button_Name)
{
   if(ObjectFind(lngG_ID,head_Button_Name)>-1) return true;
   return false;
}
//+------------------------------------------------------------------+
void delete_All_My_Buttons()
{
   for(int i=0;i<80;i++)
   {
      string strL_Button = col_Buttons[i];
      ObjectDelete(lngG_ID,strL_Button);
   }   
}
//+------------------------------------------------------------------+
//| Custom indicator DeInit function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   delete_All_My_Buttons();
   delete_OP_Line();
   ObjectDelete(ChartID(),strG_ChartName); 
   
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   //--- return value of prev_calculated for next call
   
   //manage_RR1();
   
   if(blnE_NewBar_Alert)
   if(rates_total!=prev_calculated)
      Alert(translate_TF(enmG_TF), " New Bar Alert");
   
   //
   check_FiboObjects();


   //LINIE OTWARCIA, co new bar lub new high/low
   if(ObjectGetInteger(ChartID(),strG_OPL_Button_Nazwa,OBJPROP_STATE));
   {
      if       (dblG_Daily_Mx ==-1 || dblG_Daily_Mn == -1 || dblG_Daily_Mx < iHigh(NULL,0,0) ||  dblG_Daily_Mn > iLow (NULL,0,0))   draw_OP_Line();
      else if  (rates_total!=prev_calculated)                                                            draw_OP_Line();//Alert("Rysuję OP Line z rates!=prev",Period());
      
   }
   //
   //if(prev_calculated!=rates_total || !MarketInfo(Symbol(), MODE_TRADEALLOWED))
   //{
   //   //ZLICZA TE SAME BARY
   //   //count_SameBars();    
   //   ////zlicza ile punkt urobku dzisiaj na tym rynku
   //   //count_PriceChange();
   //   //sprawdza Vipera
   //   //manage_Viper();      
   //}      
   
   //co tick kolor
   manage_OP_Line();
   
   manage_SR_Lines();
   
   
   return(rates_total);
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
//---   
   //******* CHART EVENT CLICK *******
   if( id == CHARTEVENT_OBJECT_CLICK )
   {
      //2018/06/09 zarządzanie skalą  
      if(sparam==strG_Chart_Scale_LT)
      {
         ChartSetInteger(ChartID(),CHART_SCALE,intE_Scale_LT);
         ChartSetInteger(ChartID(),CHART_MODE,CHART_BARS);
      }
      if(sparam==strG_Chart_Scale_Dn)
      {
         int intL_Scale =  ChartGetInteger(ChartID(),CHART_SCALE);
         if(intL_Scale>0)  ChartSetInteger(ChartID(),CHART_SCALE,intL_Scale-1);
      }      
      if(sparam==strG_Chart_Scale_Up)
      {
         int intL_Scale =  ChartGetInteger(ChartID(),CHART_SCALE);
         if(intL_Scale<5)  ChartSetInteger(ChartID(),CHART_SCALE,intL_Scale+1);
      }
      if(sparam==strG_Chart_Scale_ST)
      {
         ChartSetInteger (lngG_ID,CHART_SCALE,intE_Scale_ST);
         ChartSetInteger (lngG_ID,CHART_MODE,CHART_CANDLES);         
      }
      if(sparam == strG_Chart_AScroll)
      {
         bool blnL_AS = ChartGetInteger(lngG_ID,CHART_AUTOSCROLL);
         if (blnL_AS) ChartSetInteger(lngG_ID,CHART_AUTOSCROLL,false);
         else ChartSetInteger(lngG_ID,CHART_AUTOSCROLL,true);
      }    
      if(sparam == strG_Chart_Shift)
      {
         bool blnL_Shift = ChartGetInteger(lngG_ID,CHART_SHIFT);
         if (blnL_Shift) ChartSetInteger(lngG_ID,CHART_SHIFT,false);
         else ChartSetInteger(lngG_ID,CHART_SHIFT,true);
      }    
      
      //06/03/2018 - dodaję funkcjonalność, że drugi klik dezaktywuje obiekt, a kolejny aktywuje obiekt.
      if(sparam==strG_BS_Button_Nazwa)    {if(change_FiboSelectionState(strG_BS_Fibo_Nazwa))  add_BS();   ObjectSetInteger(lngG_ID,strG_BS_Button_Nazwa,OBJPROP_STATE,false);}   
      if(sparam==strG_LL_Button_Nazwa)    {if(change_FiboSelectionState(strG_LL_Fibo_Nazwa))  add_LL();   ObjectSetInteger(lngG_ID,strG_LL_Button_Nazwa,OBJPROP_STATE,false);}
      if(sparam==strG_RR_Button_Nazwa)    {if(change_FiboSelectionState(strG_RR_Fibo_Nazwa))  add_RR();   ObjectSetInteger(lngG_ID,strG_RR_Button_Nazwa,OBJPROP_STATE,false);}
      if(sparam==strG_CA_Button_Nazwa)    {if(change_FiboSelectionState(strG_CA_Fibo_Nazwa))  add_C_A();  ObjectSetInteger(lngG_ID,strG_CA_Button_Nazwa,OBJPROP_STATE,false);}
      if(sparam==strG_W5_Button_Nazwa)    {if(change_FiboSelectionState(strG_W5_Fibo_Nazwa))  add_W5();   ObjectSetInteger(lngG_ID,strG_W5_Button_Nazwa,OBJPROP_STATE,false);}      
      if(sparam==strG_OP_Button_Nazwa)    {if(change_FiboSelectionState(strG_OP_Fibo_Nazwa))  add_OP();   ObjectSetInteger(lngG_ID,strG_OP_Button_Nazwa,OBJPROP_STATE,false);}
      
      if(sparam==strG_LL1_Button_Nazwa)   {if(change_FiboSelectionState(strG_LL1_Fibo_Nazwa)) add_LL1();  ObjectSetInteger(lngG_ID,strG_LL1_Button_Nazwa,OBJPROP_STATE,false);}      
      if(sparam==strG_RR1_Button_Nazwa)   {if(change_FiboSelectionState(strG_RR1_Fibo_Nazwa)) add_RR1();  ObjectSetInteger(lngG_ID,strG_RR1_Button_Nazwa,OBJPROP_STATE,false);}
      if(sparam==strG_W15_Button_Nazwa)   {if(change_FiboSelectionState(strG_W15_Fibo_Nazwa)) add_W13x5();ObjectSetInteger(lngG_ID,strG_W15_Button_Nazwa,OBJPROP_STATE,false);}
      if(sparam==strG_W11_Button_Nazwa)   {if(change_FiboSelectionState(strG_W11_Fibo_Nazwa)) add_W11x5();ObjectSetInteger(lngG_ID,strG_W11_Button_Nazwa,OBJPROP_STATE,false);}

      //batony kasujące
      if(sparam==strG_BSc_Button_Nazwa)   {ObjectDelete(ChartID(),strG_BS_Fibo_Nazwa); change_show_buttons_prop(strG_BSh_Button_Nazwa); ObjectSetInteger(lngG_ID,strG_BSc_Button_Nazwa,OBJPROP_STATE,false);}
      if(sparam==strG_LLc_Button_Nazwa)   {ObjectDelete(ChartID(),strG_LL_Fibo_Nazwa); change_show_buttons_prop(strG_LLh_Button_Nazwa); ObjectSetInteger(lngG_ID,strG_LLc_Button_Nazwa,OBJPROP_STATE,false);}
      if(sparam==strG_RRc_Button_Nazwa)   {ObjectDelete(ChartID(),strG_RR_Fibo_Nazwa); change_show_buttons_prop(strG_RRh_Button_Nazwa); ObjectSetInteger(lngG_ID,strG_RRc_Button_Nazwa,OBJPROP_STATE,false);}
      if(sparam==strG_CAc_Button_Nazwa)   {ObjectDelete(ChartID(),strG_CA_Fibo_Nazwa); change_show_buttons_prop(strG_CAh_Button_Nazwa); ObjectSetInteger(lngG_ID,strG_CAc_Button_Nazwa,OBJPROP_STATE,false);}
      if(sparam==strG_W5c_Button_Nazwa)   {ObjectDelete(ChartID(),strG_W5_Fibo_Nazwa); change_show_buttons_prop(strG_W5h_Button_Nazwa); ObjectSetInteger(lngG_ID,strG_W5c_Button_Nazwa,OBJPROP_STATE,false);}
      if(sparam==strG_OPc_Button_Nazwa)   {ObjectDelete(ChartID(),strG_OP_Fibo_Nazwa);                                                  ObjectSetInteger(lngG_ID,strG_OPc_Button_Nazwa,OBJPROP_STATE,false);}
      if(sparam==strG_LL1c_Button_Nazwa)  {ObjectDelete(ChartID(),strG_LL1_Fibo_Nazwa);change_show_buttons_prop(strG_LL1h_Button_Nazwa);ObjectSetInteger(lngG_ID,strG_LL1c_Button_Nazwa,OBJPROP_STATE,false);}      
      if(sparam==strG_RR1c_Button_Nazwa)  {ObjectDelete(ChartID(),strG_RR1_Fibo_Nazwa);change_show_buttons_prop(strG_RR1h_Button_Nazwa);ObjectSetInteger(lngG_ID,strG_RR1c_Button_Nazwa,OBJPROP_STATE,false);}
      if(sparam==strG_W15c_Button_Nazwa)  {ObjectDelete(ChartID(),strG_W15_Fibo_Nazwa);change_show_buttons_prop(strG_W15h_Button_Nazwa);ObjectSetInteger(lngG_ID,strG_W15c_Button_Nazwa,OBJPROP_STATE,false);}
      if(sparam==strG_W11c_Button_Nazwa)  {ObjectDelete(ChartID(),strG_W11_Fibo_Nazwa);change_show_buttons_prop(strG_W11h_Button_Nazwa);ObjectSetInteger(lngG_ID,strG_W11c_Button_Nazwa,OBJPROP_STATE,false);}
            
      //kasowanie geom
      if(sparam==strG_DA_Button_Nazwa)
      {
         delete_All_Geo_All();
         ObjectSetInteger(lngG_ID,strG_DA_Button_Nazwa,OBJPROP_STATE,false);
         change_show_buttons_prop(strG_BSh_Button_Nazwa);
         change_show_buttons_prop(strG_LLh_Button_Nazwa);
         change_show_buttons_prop(strG_RRh_Button_Nazwa);
         change_show_buttons_prop(strG_CAh_Button_Nazwa); 
         change_show_buttons_prop(strG_W5h_Button_Nazwa);
         change_show_buttons_prop(strG_LL1h_Button_Nazwa);
         change_show_buttons_prop(strG_RR1h_Button_Nazwa);
         change_show_buttons_prop(strG_W15h_Button_Nazwa);
         change_show_buttons_prop(strG_W11h_Button_Nazwa);
         change_show_buttons_prop(strG_HA_Button_Nazwa);
      }
      //kolory ramek
      check_FiboObjects();
      
      
      
      //ukrywanie geom 22/06/2018
//      if(sparam==strG_HA_Button_Nazwa)
//      {
//         
//         bool blnL_Button_HideState = ObjectGetInteger(lngG_ID,strG_HA_Button_Nazwa,OBJPROP_STATE);
//         if(!blnL_Button_HideState)
//         {
//            show_Fibo_On();
//            control_ShoHide_button_state(strG_HA_Button_Nazwa,false);
//         }
//         else
//         {
//            show_Fibo_Off();
//            control_ShoHide_button_state(strG_HA_Button_Nazwa,true);
//         }
//      }
//      
      //kontrola hide/show pojedycznych geom 24/05/2019
      if(sparam==strG_HA_Button_Nazwa)    manage_hide_button_click(strG_HA_Button_Nazwa);
      if(sparam==strG_RRh_Button_Nazwa)   manage_hide_button_click(strG_RRh_Button_Nazwa, strG_RR_Fibo_Nazwa);
      if(sparam==strG_RR1h_Button_Nazwa)  manage_hide_button_click(strG_RR1h_Button_Nazwa,strG_RR1_Fibo_Nazwa);
      if(sparam==strG_LLh_Button_Nazwa)   manage_hide_button_click(strG_LLh_Button_Nazwa, strG_LL_Fibo_Nazwa);
      if(sparam==strG_LL1h_Button_Nazwa)  manage_hide_button_click(strG_LL1h_Button_Nazwa,strG_LL1_Fibo_Nazwa);
      if(sparam==strG_W5h_Button_Nazwa)   manage_hide_button_click(strG_W5h_Button_Nazwa, strG_W5_Fibo_Nazwa);
      if(sparam==strG_CAh_Button_Nazwa)   manage_hide_button_click(strG_CAh_Button_Nazwa, strG_CA_Fibo_Nazwa);
      if(sparam==strG_W15h_Button_Nazwa)  manage_hide_button_click(strG_W15h_Button_Nazwa,strG_W15_Fibo_Nazwa);
      if(sparam==strG_BSh_Button_Nazwa)   manage_hide_button_click(strG_BSh_Button_Nazwa, strG_BS_Fibo_Nazwa);
      if(sparam==strG_W11h_Button_Nazwa)  manage_hide_button_click(strG_W11h_Button_Nazwa,strG_W11_Fibo_Nazwa);

      
      //20180721 opisy geometrii 20180822 anulowane bo badziew poki co
      //manage_Fibo_Letters();
      
      //int intL_Step = intG_Step;
      
      //przesuvanie guzikov.
      //20180829 dodaję dzisisj funckonalność przesuania zestavu elliottóv
      if(sparam==strG_Arrow_Up)
      {
         move_Elliott_Up();//)  move_Buttons(0,intG_Step_V);
         ObjectSetInteger(lngG_ID,strG_Arrow_Up,OBJPROP_STATE,false);
         
      }
      if(sparam==strG_Arrow_Dn)
      {
         move_Elliott_Dn();//)  move_Buttons(0,-intG_Step_V);      
         ObjectSetInteger(lngG_ID,strG_Arrow_Dn,OBJPROP_STATE,false);
      }
      
      if(sparam == strG_Chart_Bars)    {ChartSetInteger(ChartID(),CHART_MODE,CHART_BARS);    ObjectSetInteger(lngG_ID,strG_Chart_Bars,OBJPROP_STATE,true);}
      if(sparam == strG_Chart_Candles) {ChartSetInteger(ChartID(),CHART_MODE,CHART_CANDLES); ObjectSetInteger(lngG_ID,strG_Chart_Candles,OBJPROP_STATE,true);}
      if(sparam == strG_Chart_Line)    {ChartSetInteger(ChartID(),CHART_MODE,CHART_LINE);    ObjectSetInteger(lngG_ID,strG_Chart_Line,OBJPROP_STATE,true);}
   
      if(sparam == strG_Chart_SepLines)
      {         
         bool blnL_Button_SepLinesState =  ObjectGetInteger(lngG_ID,strG_Chart_SepLines,OBJPROP_STATE);
         if(blnL_Button_SepLinesState)
         {
            ChartSetInteger(ChartID(),CHART_SHOW_PERIOD_SEP,0,true);   //seperator interwałów'
         }
         else
         {
            ChartSetInteger(ChartID(),CHART_SHOW_PERIOD_SEP,0,false);   //seperator interwałów'
         }
      }
      
      if(sparam == strG_OPL_Button_Nazwa)
      {
         bool blnL_Button_OpenPriceLineState = ObjectGetInteger(lngG_ID,strG_OPL_Button_Nazwa,OBJPROP_STATE);
         if(blnL_Button_OpenPriceLineState)
         {
            //intG_Minute = -1;
            draw_OP_Line();
         }
         else
         {
            //if(ObjectFind(lngG_ID,strG_OP_Line)>-1);
            delete_OP_Line();
            
            ObjectSetString   (ChartID(),strG_OPL_Button_Nazwa,OBJPROP_FONT,"Arial"); 
            ObjectSetInteger  (ChartID(),strG_OPL_Button_Nazwa,OBJPROP_BGCOLOR,clrSilver);
            ObjectSetInteger  (ChartID(),strG_OPL_Button_Nazwa,OBJPROP_BORDER_COLOR,clrNONE); 
         }
      }
      
      //dodatek z 14/06/2018 support resistance lines
      if(sparam == strG_SR_S_Button_Name)
      {
         draw_SR_Line(line_SR_S);
         ObjectSetInteger(lngG_ID,strG_SR_S_Button_Name,OBJPROP_STATE,false);
      }
      if(sparam == strG_SR_R_Button_Name)
      {
         draw_SR_Line(line_SR_R);
         ObjectSetInteger(lngG_ID,strG_SR_R_Button_Name,OBJPROP_STATE,false);
      }
      if(sparam == strG_SR_D_Button_Name)
      {
         delete_SR_Line();
         ObjectSetInteger(lngG_ID,strG_SR_D_Button_Name,OBJPROP_STATE,false);
      }
      
      //dodatek z 18/06 trend lines
      if(sparam == strG_TL_1_Button_Name)
      {
         draw_T_Line_Dn(STYLE_DASH);
         ObjectSetInteger(lngG_ID,strG_TL_1_Button_Name,OBJPROP_STATE,false);
      }
      if(sparam == strG_TL_2_Button_Name)
      {
         draw_T_Line_Up(STYLE_DASH);
         ObjectSetInteger(lngG_ID,strG_TL_2_Button_Name,OBJPROP_STATE,false);
      }
      if(sparam == strG_TL_d_Button_Name)
      {
         delete_T_Line();
         ObjectSetInteger(lngG_ID,strG_TL_d_Button_Name,OBJPROP_STATE,false);
      }
      
      //2019/04/26 dodatek ukrywający linie trendu
      if(sparam == strG_TL_Hide_Show_Button_Name)
      {
         bool blnL_Button_State = ObjectGetInteger(lngG_ID,strG_TL_Hide_Show_Button_Name,OBJPROP_STATE);
         if(blnL_Button_State)
         {
            show_T_Line_Off();
            control_ShoHide_button_state(strG_TL_Hide_Show_Button_Name,blnL_Button_State);//20190525
         }
         else
         {
            show_T_Line_On();
            control_ShoHide_button_state(strG_TL_Hide_Show_Button_Name,blnL_Button_State);//20190525
         }
      }
      
      //op price line
      if (sparam == strG_OPL_Button_Nazwa)
      {
         if(Period()>PERIOD_H4)
         {
            ObjectSetInteger(ChartID(),strG_OPL_Button_Nazwa,OBJPROP_STATE,false);
            Alert("Zmien TF H4 lub mniejszy do narysovania linii Open");
         }
      }
      
      //---
      if (sparam == strG_Elliott)      
      {
         bool blnL_Button_ElState = ObjectGetInteger(lngG_ID,strG_Elliott,OBJPROP_STATE);
         if(blnL_Button_ElState)
         {
             add_Waves();
             ObjectSetInteger(lngG_ID,strG_Elliott,OBJPROP_STATE,true);
         }
         else
         {
            ObjectSetInteger(lngG_ID,strG_Elliott,OBJPROP_STATE,false);
            delete_Waves();
         }
      }     
   //-
   }
   
   //******* CHART EVENT CHANGE *******
   else if (id == CHARTEVENT_CHART_CHANGE)
   {      
      check_BarsAndCandles();
      if(ChartGetInteger(ChartID(),CHART_SCALE)==0)   ObjectSetInteger(lngG_ID,strG_Chart_Scale_Dn,OBJPROP_STATE,true); else ObjectSetInteger(lngG_ID,strG_Chart_Scale_Dn,OBJPROP_STATE,false);
      if(ChartGetInteger(ChartID(),CHART_SCALE)==5)   ObjectSetInteger(lngG_ID,strG_Chart_Scale_Up,OBJPROP_STATE,true); else ObjectSetInteger(lngG_ID,strG_Chart_Scale_Up,OBJPROP_STATE,false);
      if(ChartGetInteger(lngG_ID,CHART_AUTOSCROLL))   ObjectSetInteger(lngG_ID,strG_Chart_AScroll,OBJPROP_STATE,true);  else ObjectSetInteger(lngG_ID,strG_Chart_AScroll,OBJPROP_STATE,false);
      if(ChartGetInteger(lngG_ID,CHART_SHIFT))        ObjectSetInteger(lngG_ID,strG_Chart_Shift,OBJPROP_STATE,true);    else ObjectSetInteger(lngG_ID,strG_Chart_Shift,OBJPROP_STATE,false);
      
      // pozycja guzika long term
      if(ChartGetInteger(lngG_ID,CHART_SCALE)==intE_Scale_LT && ChartGetInteger(ChartID(),CHART_MODE)== CHART_BARS)
         ObjectSetInteger(lngG_ID,strG_Chart_Scale_LT,OBJPROP_STATE,true);
      else
         ObjectSetInteger(lngG_ID,strG_Chart_Scale_LT,OBJPROP_STATE,false);

      // pozycja guzika short term
      if(ChartGetInteger(lngG_ID,CHART_SCALE)==intE_Scale_ST && ChartGetInteger(ChartID(),CHART_MODE)== CHART_CANDLES)
         ObjectSetInteger(lngG_ID,strG_Chart_Scale_ST,OBJPROP_STATE,true);
      else
         ObjectSetInteger(lngG_ID,strG_Chart_Scale_ST,OBJPROP_STATE,false);
               
      //PRZYCINA I DEZAKTYVUJE linie SR do bieżącej śviecy
      adjust_SR_Line();
      
      //20180622 kontrola guzika ukrvyania. 
      //20190525 dodałem serie guzików
      control_ShoHide_button_state(strG_HA_Button_Nazwa,check_Fibo_Off(strG_HA_Button_Nazwa));
      control_ShoHide_button_state(strG_RRh_Button_Nazwa,check_Fibo_Off(strG_RRh_Button_Nazwa,     strG_RR_Fibo_Nazwa));
      control_ShoHide_button_state(strG_RR1h_Button_Nazwa,check_Fibo_Off(strG_RR1h_Button_Nazwa,   strG_RR1_Fibo_Nazwa));
      control_ShoHide_button_state(strG_LLh_Button_Nazwa,check_Fibo_Off(strG_LLh_Button_Nazwa,     strG_LL_Fibo_Nazwa));
      control_ShoHide_button_state(strG_LL1h_Button_Nazwa,check_Fibo_Off(strG_LL1h_Button_Nazwa,   strG_LL1_Fibo_Nazwa));
      control_ShoHide_button_state(strG_W5h_Button_Nazwa,check_Fibo_Off(strG_W5h_Button_Nazwa,     strG_W5_Fibo_Nazwa));
      control_ShoHide_button_state(strG_CAh_Button_Nazwa,check_Fibo_Off(strG_CAh_Button_Nazwa,     strG_CA_Fibo_Nazwa));
      control_ShoHide_button_state(strG_W15h_Button_Nazwa,check_Fibo_Off(strG_W15h_Button_Nazwa,   strG_W15_Fibo_Nazwa));
      control_ShoHide_button_state(strG_BSh_Button_Nazwa,check_Fibo_Off(strG_BSh_Button_Nazwa,     strG_BS_Fibo_Nazwa));
      control_ShoHide_button_state(strG_W11h_Button_Nazwa,check_Fibo_Off(strG_W11h_Button_Nazwa,   strG_W11_Fibo_Nazwa));

      control_ShoHide_button_state(strG_TL_Hide_Show_Button_Name,check_TL_Off());
   }
   //fale elliotta, strzałki i linie trendu po przesunięciu od razu niaktyvne
   else if (id == CHARTEVENT_OBJECT_DRAG)
   {
      if(StringSubstr(sparam,0,2) == "el" || StringSubstr(sparam,0,5) == "Arrow" || StringSubstr(sparam,0,3) == "TL ")
         ObjectSetInteger(lngG_ID,sparam,OBJPROP_SELECTED,false);
   }
   
}
//+------------------------------------------------------------------+
bool check_Fibo_Off(string head_Button_name,const string head_Fibo_name = "*")
{
   if(head_Button_name == strG_HA_Button_Nazwa)
   {
      for(int i=1;i<26;i++)
      {
         string strL_Name = col_Fibo[i];
         if (ObjectGetInteger(lngG_ID,strL_Name,OBJPROP_LEVELCOLOR) == clrNONE) return true;
      }
   }
   else
   {
      for(int i=1;i<26;i++)
      {
         string strL_Name = col_Fibo[i];
         if (head_Fibo_name == strL_Name)
         if (ObjectGetInteger(lngG_ID,strL_Name,OBJPROP_LEVELCOLOR) == clrNONE)
            return true;
      }
   }  
   return false;
}
//+------------------------------------------------------------------+
void  manage_hide_button_click(string head_Button_Nazwa, const string head_Fibo_nazwa = "*")
{
   bool blnL_Button_HideState = ObjectGetInteger(lngG_ID,head_Button_Nazwa,OBJPROP_STATE);
   
   if(!blnL_Button_HideState)
   {
      show_Fibo_On(head_Fibo_nazwa);
      control_ShoHide_button_state(head_Button_Nazwa,blnL_Button_HideState);
   }
   else
   {
      show_Fibo_Off(head_Fibo_nazwa);
      control_ShoHide_button_state(head_Button_Nazwa,blnL_Button_HideState);
   }
}
//+------------------------------------------------------------------+
void control_ShoHide_button_state(string head_ButtonName, bool head_ShoHide)
{
   if(head_ShoHide)
   {      
      change_hide_buttons_prop(head_ButtonName);
   }
   else
   {
      if(head_ButtonName == strG_HA_Button_Nazwa)
      {
         change_show_buttons_prop(strG_HA_Button_Nazwa);
         change_show_buttons_prop(strG_RRh_Button_Nazwa);
         change_show_buttons_prop(strG_RR1h_Button_Nazwa);
         change_show_buttons_prop(strG_LLh_Button_Nazwa);
         change_show_buttons_prop(strG_LL1h_Button_Nazwa);
         change_show_buttons_prop(strG_W5h_Button_Nazwa);
         change_show_buttons_prop(strG_CAh_Button_Nazwa);
         change_show_buttons_prop(strG_W15h_Button_Nazwa);
         change_show_buttons_prop(strG_BSh_Button_Nazwa);
         change_show_buttons_prop(strG_W11h_Button_Nazwa);
      }
      else
         change_show_buttons_prop(head_ButtonName);
   }
}
//+------------------------------------------------------------------+
void change_hide_buttons_prop(string head_ButtonName)
{
      ObjectSetInteger(lngG_ID,head_ButtonName,OBJPROP_STATE,true);
      ObjectSetInteger(lngG_ID,head_ButtonName,OBJPROP_COLOR,clrRed);
      ObjectSetInteger(lngG_ID,head_ButtonName,OBJPROP_BGCOLOR,clrBlack);
      ObjectSetInteger(lngG_ID,head_ButtonName,OBJPROP_BORDER_COLOR,clrRed);
      if(head_ButtonName == strG_HA_Button_Nazwa)  ObjectSetString(lngG_ID,head_ButtonName,OBJPROP_TEXT,"Show");
      else                                         ObjectSetString(lngG_ID,head_ButtonName,OBJPROP_TEXT,"s");
}
//+------------------------------------------------------------------+
void change_show_buttons_prop(string head_ButtonName)
{
      ObjectSetInteger(lngG_ID,head_ButtonName,OBJPROP_STATE,false);
      ObjectSetInteger(lngG_ID,head_ButtonName,OBJPROP_COLOR,clrBlack);
      ObjectSetInteger(lngG_ID,head_ButtonName,OBJPROP_BGCOLOR,C'236,233,216');
      ObjectSetInteger(lngG_ID,head_ButtonName,OBJPROP_BORDER_COLOR,clrNONE);
      if(head_ButtonName == strG_HA_Button_Nazwa)  ObjectSetString(lngG_ID,head_ButtonName,OBJPROP_TEXT,"Hide"); 
      else                                         ObjectSetString(lngG_ID,head_ButtonName,OBJPROP_TEXT,"h");
}
//+------------------------------------------------------------------+
int calc_I0()
{
   //20180501
   int intL_FBoC = WindowFirstVisibleBar();
   int intL_MBoC = intL_FBoC - .3 * WindowBarsPerChart();     
   return intL_MBoC;
}
//+------------------------------------------------------------------+
int calc_I1()
{
   int intL_I1 = calc_I0()-21;
   if(intL_I1<8) intL_I1 = 8;
   return intL_I1;
}
//+------------------------------------------------------------------+
int calc_I2()
{
   int intL_I2 =  calc_I0()- 34;
   if (intL_I2<0) intL_I2 = 0;
   return intL_I2;
}
//+------------------------------------------------------------------+
double calc_P0()
{
   double dblL_Price_Max   = WindowPriceMax();
   double dblL_Price_Min   = WindowPriceMin();
   double dblL_Price_Range = dblL_Price_Max - dblL_Price_Min;
   
   return dblL_Price_Max - .2*dblL_Price_Range;
}
//+------------------------------------------------------------------+
double calc_P1()
{
   double dblL_Price_Max   = WindowPriceMax();
   double dblL_Price_Min   = WindowPriceMin();
   double dblL_Price_Range = dblL_Price_Max - dblL_Price_Min;
   
   return dblL_Price_Max - .7*dblL_Price_Range;
}
//+------------------------------------------------------------------+
double calc_P2()
{
   double dblL_Price_Max   = WindowPriceMax();
   double dblL_Price_Min   = WindowPriceMin();
   double dblL_Price_Range = dblL_Price_Max - dblL_Price_Min;
   
   return dblL_Price_Max - .3*dblL_Price_Range;
}
////+------------------------------------------------------------------+
//void read_Objects_Base_Position_XY() /// w fazie rozwoju 2018531
//{
//   for(int i=0;i<=80;i++)
//   {
//      string strL_Button = col_Buttons[i];
//      int x_0, y_0;
//
//      x_0 = ObjectGetInteger(lngG_ID,strL_Button,OBJPROP_XDISTANCE);
//      y_0 = ObjectGetInteger(lngG_ID,strL_Button,OBJPROP_YDISTANCE);
//      
//      col_X[i] = x_0;
//      col_Y[i] = y_0;
//   }
//}
////+------------------------------------------------------------------+ 
//bool move_Buttons( const int    x=0,           // X coordinate 
//                   const int    y=0)           // Y coordinate 
//{
//   for(int i=0;i<=80;i++)
//   {
//      string strL_Button = col_Buttons[i];
//      ENUM_BASE_CORNER crnL_Corner = ObjectGetInteger(lngG_ID,strL_Button,OBJPROP_CORNER);
//
//      int x_0, y_0;
//      x_0 = ObjectGetInteger(lngG_ID,strL_Button,OBJPROP_XDISTANCE);
//      y_0 = ObjectGetInteger(lngG_ID,strL_Button,OBJPROP_YDISTANCE);      
//      
//      if    (crnL_Corner == CORNER_RIGHT_LOWER) ObjectSetInteger(lngG_ID,strL_Button,OBJPROP_XDISTANCE,x_0+x); 
//      else                                      ObjectSetInteger(lngG_ID,strL_Button,OBJPROP_XDISTANCE,x_0-x); 
//      
//      if    (crnL_Corner == CORNER_LEFT_UPPER)  ObjectSetInteger(lngG_ID,strL_Button,OBJPROP_YDISTANCE,y_0-y);
//      else  ObjectSetInteger(lngG_ID,strL_Button,OBJPROP_YDISTANCE,y_0+y);
//   }
//   return true;      
//}
////+------------------------------------------------------------------+ 
//void move_Buttons_To_Theirs_Base_Position()
//{
//   for(int i=0;i<=80;i++)
//   {
//      string strL_Button = col_Buttons[i];
//      int x_0 = col_X[i];
//      int y_0 = col_Y[i];
//      ObjectSetInteger(lngG_ID,strL_Button,OBJPROP_XDISTANCE,x_0); ObjectSetInteger(lngG_ID,strL_Button,OBJPROP_YDISTANCE,y_0);
//      ObjectSetInteger(lngG_ID,strL_Button,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
//   }
//}
////+------------------------------------------------------------------+ 
//void move_Buttons_To_The_Left()
//{
//   int intL_X = intG_X-94;
//
//   //bar count
//   ObjectSetInteger(lngG_ID,strG_Shade_BarCount,OBJPROP_XDISTANCE,intL_X+75);ObjectSetInteger(lngG_ID,strG_Shade_BarCount,OBJPROP_YDISTANCE,intG_Y+34); ObjectSetInteger(lngG_ID,strG_Shade_BarCount,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_Label_BarCount,OBJPROP_XDISTANCE,intL_X+78);ObjectSetInteger(lngG_ID,strG_Label_BarCount,OBJPROP_YDISTANCE,intG_Y+34); ObjectSetInteger(lngG_ID,strG_Label_BarCount,OBJPROP_CORNER,CORNER_LEFT_LOWER);   
//   //CHANGE IN POINTS
//   //ObjectSetInteger(lngG_ID,strG_Shade_Change,OBJPROP_XDISTANCE,intL_X+00);   ObjectSetInteger(lngG_ID,strG_Shade_Change,OBJPROP_YDISTANCE,intG_Y+34);   ObjectSetInteger(lngG_ID,strG_Shade_Change,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   //ObjectSetInteger(lngG_ID,strG_Label_Change,OBJPROP_XDISTANCE,intL_X+34);   ObjectSetInteger(lngG_ID,strG_Label_Change,OBJPROP_YDISTANCE,intG_Y+30);   ObjectSetInteger(lngG_ID,strG_Label_Change,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   
//   //przesuwaki
//   ObjectSetInteger(lngG_ID,strG_Arrow_Up,OBJPROP_XDISTANCE,intL_X+42);      ObjectSetInteger(lngG_ID,strG_Arrow_Up,OBJPROP_YDISTANCE,intG_Y+24); ObjectSetInteger(lngG_ID,strG_Arrow_Up,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_Arrow_Dn,OBJPROP_XDISTANCE,intL_X+20);      ObjectSetInteger(lngG_ID,strG_Arrow_Dn,OBJPROP_YDISTANCE,intG_Y-153); ObjectSetInteger(lngG_ID,strG_Arrow_Dn,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_Arrow_Lf,OBJPROP_XDISTANCE,intL_X-15);      ObjectSetInteger(lngG_ID,strG_Arrow_Lf,OBJPROP_YDISTANCE,intG_Y-67); ObjectSetInteger(lngG_ID,strG_Arrow_Lf,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_Arrow_Rt,OBJPROP_XDISTANCE,intL_X+97);      ObjectSetInteger(lngG_ID,strG_Arrow_Rt,OBJPROP_YDISTANCE,intG_Y-67); ObjectSetInteger(lngG_ID,strG_Arrow_Rt,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   //zarzadzanie ekranem
//   ObjectSetInteger(lngG_ID,strG_Chart_Scale_LT,OBJPROP_XDISTANCE,intL_X);    ObjectSetInteger(lngG_ID,strG_Chart_Scale_LT,OBJPROP_YDISTANCE,intG_Y+9); ObjectSetInteger(lngG_ID,strG_Chart_Scale_LT,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_Chart_Scale_Dn,OBJPROP_XDISTANCE,intL_X+24); ObjectSetInteger(lngG_ID,strG_Chart_Scale_Dn,OBJPROP_YDISTANCE,intG_Y+9); ObjectSetInteger(lngG_ID,strG_Chart_Scale_Dn,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_Chart_Scale_Up,OBJPROP_XDISTANCE,intL_X+48); ObjectSetInteger(lngG_ID,strG_Chart_Scale_Up,OBJPROP_YDISTANCE,intG_Y+9); ObjectSetInteger(lngG_ID,strG_Chart_Scale_Up,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_Chart_Scale_ST,OBJPROP_XDISTANCE,intL_X+72); ObjectSetInteger(lngG_ID,strG_Chart_Scale_ST,OBJPROP_YDISTANCE,intG_Y+9); ObjectSetInteger(lngG_ID,strG_Chart_Scale_ST,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   
//   ObjectSetInteger(lngG_ID,strG_Chart_Bars,    OBJPROP_XDISTANCE,intL_X+24); ObjectSetInteger(lngG_ID,strG_Chart_Bars,    OBJPROP_YDISTANCE,intG_Y-5);  ObjectSetInteger(lngG_ID,strG_Chart_Bars,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_Chart_Candles, OBJPROP_XDISTANCE,intL_X+40); ObjectSetInteger(lngG_ID,strG_Chart_Candles, OBJPROP_YDISTANCE,intG_Y-5);  ObjectSetInteger(lngG_ID,strG_Chart_Candles,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_Chart_Line,    OBJPROP_XDISTANCE,intL_X+56); ObjectSetInteger(lngG_ID,strG_Chart_Line,    OBJPROP_YDISTANCE,intG_Y-5);  ObjectSetInteger(lngG_ID,strG_Chart_Line,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   
//   ObjectSetInteger(lngG_ID,strG_Chart_AScroll, OBJPROP_XDISTANCE,intL_X);    ObjectSetInteger(lngG_ID,strG_Chart_AScroll, OBJPROP_YDISTANCE,intG_Y-20);  ObjectSetInteger(lngG_ID,strG_Chart_AScroll,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_Chart_Shift,   OBJPROP_XDISTANCE,intL_X+30); ObjectSetInteger(lngG_ID,strG_Chart_Shift,   OBJPROP_YDISTANCE,intG_Y-20);    ObjectSetInteger(lngG_ID,strG_Chart_Shift,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_Chart_SepLines,OBJPROP_XDISTANCE,intL_X+68); ObjectSetInteger(lngG_ID,strG_Chart_SepLines,OBJPROP_YDISTANCE,intG_Y-20); ObjectSetInteger(lngG_ID,strG_Chart_SepLines,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   //pierwsza kolumna
//   ObjectSetInteger(lngG_ID,strG_RR_Button_Nazwa,OBJPROP_XDISTANCE,intL_X); ObjectSetInteger(lngG_ID,strG_RR_Button_Nazwa,OBJPROP_YDISTANCE,intG_Y-39); ObjectSetInteger(lngG_ID,strG_RR_Button_Nazwa,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_LL_Button_Nazwa,OBJPROP_XDISTANCE,intL_X); ObjectSetInteger(lngG_ID,strG_LL_Button_Nazwa,OBJPROP_YDISTANCE,intG_Y-57); ObjectSetInteger(lngG_ID,strG_LL_Button_Nazwa,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_BS_Button_Nazwa,OBJPROP_XDISTANCE,intL_X); ObjectSetInteger(lngG_ID,strG_BS_Button_Nazwa,OBJPROP_YDISTANCE,intG_Y-75); ObjectSetInteger(lngG_ID,strG_BS_Button_Nazwa,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_W5_Button_Nazwa,OBJPROP_XDISTANCE,intL_X); ObjectSetInteger(lngG_ID,strG_W5_Button_Nazwa,OBJPROP_YDISTANCE,intG_Y-93); ObjectSetInteger(lngG_ID,strG_W5_Button_Nazwa,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   //druga kolumna - kasowania
//   ObjectSetInteger(lngG_ID,strG_RRc_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+29); ObjectSetInteger(lngG_ID,strG_RRc_Button_Nazwa,OBJPROP_YDISTANCE,intG_Y-39); ObjectSetInteger(lngG_ID,strG_RRc_Button_Nazwa,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_LLc_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+29); ObjectSetInteger(lngG_ID,strG_LLc_Button_Nazwa,OBJPROP_YDISTANCE,intG_Y-57); ObjectSetInteger(lngG_ID,strG_LLc_Button_Nazwa,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_BSc_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+29); ObjectSetInteger(lngG_ID,strG_BSc_Button_Nazwa,OBJPROP_YDISTANCE,intG_Y-75); ObjectSetInteger(lngG_ID,strG_BSc_Button_Nazwa,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_W5c_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+29); ObjectSetInteger(lngG_ID,strG_W5c_Button_Nazwa,OBJPROP_YDISTANCE,intG_Y-93); ObjectSetInteger(lngG_ID,strG_W5c_Button_Nazwa,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   //trzecia kolumna
//   ObjectSetInteger(lngG_ID,strG_RR1_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+48); ObjectSetInteger(lngG_ID,strG_RR1_Button_Nazwa,OBJPROP_YDISTANCE,intG_Y-39); ObjectSetInteger(lngG_ID,strG_RR1_Button_Nazwa,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_LL1_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+48); ObjectSetInteger(lngG_ID,strG_LL1_Button_Nazwa,OBJPROP_YDISTANCE,intG_Y-57); ObjectSetInteger(lngG_ID,strG_LL1_Button_Nazwa,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_CA_Button_Nazwa, OBJPROP_XDISTANCE,intL_X+48);  ObjectSetInteger(lngG_ID,strG_CA_Button_Nazwa,OBJPROP_YDISTANCE,intG_Y-75);  ObjectSetInteger(lngG_ID,strG_CA_Button_Nazwa,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_W15_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+48); ObjectSetInteger(lngG_ID,strG_W15_Button_Nazwa,OBJPROP_YDISTANCE,intG_Y-93); ObjectSetInteger(lngG_ID,strG_W15_Button_Nazwa,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   //czwarta kolumna kasowania
//   ObjectSetInteger(lngG_ID,strG_RR1c_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+77); ObjectSetInteger(lngG_ID,strG_RR1c_Button_Nazwa,OBJPROP_YDISTANCE,intG_Y-39); ObjectSetInteger(lngG_ID,strG_RR1c_Button_Nazwa,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_LL1c_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+77); ObjectSetInteger(lngG_ID,strG_LL1c_Button_Nazwa,OBJPROP_YDISTANCE,intG_Y-57); ObjectSetInteger(lngG_ID,strG_LL1c_Button_Nazwa,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_CAc_Button_Nazwa, OBJPROP_XDISTANCE,intL_X+77); ObjectSetInteger(lngG_ID,strG_CAc_Button_Nazwa, OBJPROP_YDISTANCE,intG_Y-75); ObjectSetInteger(lngG_ID,strG_CAc_Button_Nazwa,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_W15c_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+77); ObjectSetInteger(lngG_ID,strG_W15c_Button_Nazwa,OBJPROP_YDISTANCE,intG_Y-93); ObjectSetInteger(lngG_ID,strG_W15c_Button_Nazwa,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   //*****cena otwarcia*****
//   ObjectSetInteger(lngG_ID,strG_OP_Button_Nazwa,OBJPROP_XDISTANCE,intL_X);      ObjectSetInteger(lngG_ID,strG_OP_Button_Nazwa,OBJPROP_YDISTANCE,intG_Y-112);  ObjectSetInteger(lngG_ID,strG_OP_Button_Nazwa,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_OPc_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+20);  ObjectSetInteger(lngG_ID,strG_OPc_Button_Nazwa,OBJPROP_YDISTANCE,intG_Y-112); ObjectSetInteger(lngG_ID,strG_OPc_Button_Nazwa,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_OPL_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+32);  ObjectSetInteger(lngG_ID,strG_OPL_Button_Nazwa,OBJPROP_YDISTANCE,intG_Y-112); ObjectSetInteger(lngG_ID,strG_OPL_Button_Nazwa,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   //*** W1:5 czyli W11
//   ObjectSetInteger(lngG_ID,strG_W11_Button_Nazwa,OBJPROP_XDISTANCE,intL_X +48); ObjectSetInteger(lngG_ID,strG_W11_Button_Nazwa,OBJPROP_YDISTANCE,intG_Y-111); ObjectSetInteger(lngG_ID,strG_W11_Button_Nazwa,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_W11c_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+77); ObjectSetInteger(lngG_ID,strG_W11c_Button_Nazwa,OBJPROP_YDISTANCE,intG_Y-111);ObjectSetInteger(lngG_ID,strG_W11c_Button_Nazwa,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   //*****SR Lines*****
//   ObjectSetInteger(lngG_ID,strG_SR_S_Button_Name,OBJPROP_XDISTANCE,intL_X+96);  ObjectSetInteger(lngG_ID,strG_SR_S_Button_Name,OBJPROP_YDISTANCE,intG_Y-101); ObjectSetInteger(lngG_ID,strG_SR_S_Button_Name,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_SR_R_Button_Name,OBJPROP_XDISTANCE,intL_X+96);  ObjectSetInteger(lngG_ID,strG_SR_R_Button_Name,OBJPROP_YDISTANCE,intG_Y-117); ObjectSetInteger(lngG_ID,strG_SR_R_Button_Name,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   //ObjectSetInteger(lngG_ID,strG_SR_C_Button_Name,OBJPROP_XDISTANCE,intL_X+96);  ObjectSetInteger(lngG_ID,strG_SR_C_Button_Name,OBJPROP_YDISTANCE,intG_Y-117); ObjectSetInteger(lngG_ID,strG_SR_C_Button_Name,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_SR_D_Button_Name,OBJPROP_XDISTANCE,intL_X+96);  ObjectSetInteger(lngG_ID,strG_SR_D_Button_Name,OBJPROP_YDISTANCE,intG_Y-133); ObjectSetInteger(lngG_ID,strG_SR_D_Button_Name,OBJPROP_CORNER,CORNER_LEFT_LOWER); 
//   //***** trend lines ***** (18/06)
//   ObjectSetInteger(lngG_ID,strG_TL_1_Button_Name,OBJPROP_XDISTANCE,intL_X+96);  ObjectSetInteger(lngG_ID,strG_TL_1_Button_Name,OBJPROP_YDISTANCE,intG_Y-12); ObjectSetInteger(lngG_ID,strG_TL_1_Button_Name,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_TL_2_Button_Name,OBJPROP_XDISTANCE,intL_X+96);  ObjectSetInteger(lngG_ID,strG_TL_2_Button_Name,OBJPROP_YDISTANCE,intG_Y-28); ObjectSetInteger(lngG_ID,strG_TL_2_Button_Name,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_TL_d_Button_Name,OBJPROP_XDISTANCE,intL_X+96);  ObjectSetInteger(lngG_ID,strG_TL_d_Button_Name,OBJPROP_YDISTANCE,intG_Y-44); ObjectSetInteger(lngG_ID,strG_TL_d_Button_Name,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   //ELLIOTT (7/08/2018)
//   ObjectSetInteger(lngG_ID,strG_Elliott,OBJPROP_XDISTANCE,intL_X+96);  ObjectSetInteger(lngG_ID,strG_Elliott,OBJPROP_YDISTANCE,intG_Y+9); ObjectSetInteger(lngG_ID,strG_Elliott,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//     
//   //kasuj wszystko
//   ObjectSetInteger(lngG_ID,strG_DA_Button_Nazwa,OBJPROP_XDISTANCE,intL_X);      ObjectSetInteger(lngG_ID,strG_DA_Button_Nazwa,OBJPROP_YDISTANCE,intG_Y-131); ObjectSetInteger(lngG_ID,strG_DA_Button_Nazwa,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   //ukryj wszystko - hide all
//   ObjectSetInteger(lngG_ID,strG_HA_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+62);   ObjectSetInteger(lngG_ID,strG_HA_Button_Nazwa,OBJPROP_YDISTANCE,intG_Y-131); ObjectSetInteger(lngG_ID,strG_HA_Button_Nazwa,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//
//   //create Viper Info
//   ObjectSetInteger(lngG_ID,strG_Shade_Viper,OBJPROP_XDISTANCE,intL_X+32);  ObjectSetInteger(lngG_ID,strG_Shade_Viper,OBJPROP_YDISTANCE,intG_Y-151); ObjectSetInteger(lngG_ID,strG_Shade_Viper,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//   ObjectSetInteger(lngG_ID,strG_Label_Viper,OBJPROP_XDISTANCE,intL_X+35);  ObjectSetInteger(lngG_ID,strG_Label_Viper,OBJPROP_YDISTANCE,intG_Y-152); ObjectSetInteger(lngG_ID,strG_Label_Viper,OBJPROP_CORNER,CORNER_LEFT_LOWER);
//
//}
////+------------------------------------------------------------------+ 
//void move_Buttons_To_The_Left_Upper()
//{
//   int intL_X = intG_X-94;
//   int intL_Y = 56;
//   
//   for(int i=0;i<=80;i++)
//   {
//      string strL_Button = col_Buttons[i];
//      ObjectSetInteger(lngG_ID,strL_Button,OBJPROP_CORNER,CORNER_LEFT_UPPER);
//   }
//   //bar count
//   ObjectSetInteger(lngG_ID,strG_Shade_BarCount,OBJPROP_XDISTANCE,intL_X+75);ObjectSetInteger(lngG_ID,strG_Shade_BarCount,OBJPROP_YDISTANCE,intL_Y-33);
//   ObjectSetInteger(lngG_ID,strG_Label_BarCount,OBJPROP_XDISTANCE,intL_X+78);ObjectSetInteger(lngG_ID,strG_Label_BarCount,OBJPROP_YDISTANCE,intL_Y-33);
//   //CHANGE IN POINTS
//   //ObjectSetInteger(lngG_ID,strG_Shade_Change,  OBJPROP_XDISTANCE,intL_X+00);ObjectSetInteger(lngG_ID,strG_Shade_Change,OBJPROP_YDISTANCE,intL_Y-34);
//   //ObjectSetInteger(lngG_ID,strG_Label_Change,  OBJPROP_XDISTANCE,intL_X+34);ObjectSetInteger(lngG_ID,strG_Label_Change,OBJPROP_YDISTANCE,intL_Y-30);
//   
//   //przesuwaki
//   ObjectSetInteger(lngG_ID,strG_Arrow_Up,OBJPROP_XDISTANCE,intL_X+42); ObjectSetInteger(lngG_ID,strG_Arrow_Up,OBJPROP_YDISTANCE,intL_Y-24);
//   ObjectSetInteger(lngG_ID,strG_Arrow_Dn,OBJPROP_XDISTANCE,intL_X+42); ObjectSetInteger(lngG_ID,strG_Arrow_Dn,OBJPROP_YDISTANCE,intL_Y+153);
//   ObjectSetInteger(lngG_ID,strG_Arrow_Lf,OBJPROP_XDISTANCE,intL_X-15); ObjectSetInteger(lngG_ID,strG_Arrow_Lf,OBJPROP_YDISTANCE,intL_Y+67);
//   ObjectSetInteger(lngG_ID,strG_Arrow_Rt,OBJPROP_XDISTANCE,intL_X+97); ObjectSetInteger(lngG_ID,strG_Arrow_Rt,OBJPROP_YDISTANCE,intL_Y+67);
//   //zarzadzanie ekranem
//   ObjectSetInteger(lngG_ID,strG_Chart_Scale_LT,   OBJPROP_XDISTANCE,intL_X);    ObjectSetInteger(lngG_ID,strG_Chart_Scale_LT,OBJPROP_YDISTANCE,intL_Y-9);
//   ObjectSetInteger(lngG_ID,strG_Chart_Scale_Dn,   OBJPROP_XDISTANCE,intL_X+24); ObjectSetInteger(lngG_ID,strG_Chart_Scale_Dn,OBJPROP_YDISTANCE,intL_Y-9);
//   ObjectSetInteger(lngG_ID,strG_Chart_Scale_Up,   OBJPROP_XDISTANCE,intL_X+48); ObjectSetInteger(lngG_ID,strG_Chart_Scale_Up,OBJPROP_YDISTANCE,intL_Y-9);
//   ObjectSetInteger(lngG_ID,strG_Chart_Scale_ST,   OBJPROP_XDISTANCE,intL_X+72); ObjectSetInteger(lngG_ID,strG_Chart_Scale_ST,OBJPROP_YDISTANCE,intL_Y-9);
//
//   ObjectSetInteger(lngG_ID,strG_Chart_Bars,       OBJPROP_XDISTANCE,intL_X+24); ObjectSetInteger(lngG_ID,strG_Chart_Bars,    OBJPROP_YDISTANCE,intL_Y+5);
//   ObjectSetInteger(lngG_ID,strG_Chart_Candles,    OBJPROP_XDISTANCE,intL_X+40); ObjectSetInteger(lngG_ID,strG_Chart_Candles, OBJPROP_YDISTANCE,intL_Y+5);
//   ObjectSetInteger(lngG_ID,strG_Chart_Line,       OBJPROP_XDISTANCE,intL_X+56); ObjectSetInteger(lngG_ID,strG_Chart_Line,    OBJPROP_YDISTANCE,intL_Y+5);
//
//   ObjectSetInteger(lngG_ID,strG_Chart_AScroll,    OBJPROP_XDISTANCE,intL_X);    ObjectSetInteger(lngG_ID,strG_Chart_AScroll, OBJPROP_YDISTANCE,intL_Y+20);
//   ObjectSetInteger(lngG_ID,strG_Chart_Shift,      OBJPROP_XDISTANCE,intL_X+30); ObjectSetInteger(lngG_ID,strG_Chart_Shift,   OBJPROP_YDISTANCE,intL_Y+20);
//   ObjectSetInteger(lngG_ID,strG_Chart_SepLines,   OBJPROP_XDISTANCE,intL_X+68); ObjectSetInteger(lngG_ID,strG_Chart_SepLines,OBJPROP_YDISTANCE,intL_Y+20);
//   //pierwsza kolumna
//   ObjectSetInteger(lngG_ID,strG_RR_Button_Nazwa,  OBJPROP_XDISTANCE,intL_X);    ObjectSetInteger(lngG_ID,strG_RR_Button_Nazwa,OBJPROP_YDISTANCE,intL_Y+39);
//   ObjectSetInteger(lngG_ID,strG_LL_Button_Nazwa,  OBJPROP_XDISTANCE,intL_X);    ObjectSetInteger(lngG_ID,strG_LL_Button_Nazwa,OBJPROP_YDISTANCE,intL_Y+57);
//   ObjectSetInteger(lngG_ID,strG_BS_Button_Nazwa,  OBJPROP_XDISTANCE,intL_X);    ObjectSetInteger(lngG_ID,strG_BS_Button_Nazwa,OBJPROP_YDISTANCE,intL_Y+75);
//   ObjectSetInteger(lngG_ID,strG_W5_Button_Nazwa,  OBJPROP_XDISTANCE,intL_X);    ObjectSetInteger(lngG_ID,strG_W5_Button_Nazwa,OBJPROP_YDISTANCE,intL_Y+93);
//   //druga kolumna - kasowania
//   ObjectSetInteger(lngG_ID,strG_RRc_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+29); ObjectSetInteger(lngG_ID,strG_RRc_Button_Nazwa,OBJPROP_YDISTANCE,intL_Y+39);
//   ObjectSetInteger(lngG_ID,strG_LLc_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+29); ObjectSetInteger(lngG_ID,strG_LLc_Button_Nazwa,OBJPROP_YDISTANCE,intL_Y+57);
//   ObjectSetInteger(lngG_ID,strG_BSc_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+29); ObjectSetInteger(lngG_ID,strG_BSc_Button_Nazwa,OBJPROP_YDISTANCE,intL_Y+75);
//   ObjectSetInteger(lngG_ID,strG_W5c_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+29); ObjectSetInteger(lngG_ID,strG_W5c_Button_Nazwa,OBJPROP_YDISTANCE,intL_Y+93);   
//   //trzecia kolumna
//   ObjectSetInteger(lngG_ID,strG_RR1_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+48); ObjectSetInteger(lngG_ID,strG_RR1_Button_Nazwa,OBJPROP_YDISTANCE,intL_Y+39);
//   ObjectSetInteger(lngG_ID,strG_LL1_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+48); ObjectSetInteger(lngG_ID,strG_LL1_Button_Nazwa,OBJPROP_YDISTANCE,intL_Y+57);
//   ObjectSetInteger(lngG_ID,strG_CA_Button_Nazwa, OBJPROP_XDISTANCE,intL_X+48); ObjectSetInteger(lngG_ID,strG_CA_Button_Nazwa, OBJPROP_YDISTANCE,intL_Y+75);
//   ObjectSetInteger(lngG_ID,strG_W15_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+48); ObjectSetInteger(lngG_ID,strG_W15_Button_Nazwa,OBJPROP_YDISTANCE,intL_Y+93);
//   //czwarta kolumna kasowania
//   ObjectSetInteger(lngG_ID,strG_RR1c_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+77); ObjectSetInteger(lngG_ID,strG_RR1c_Button_Nazwa,OBJPROP_YDISTANCE,intL_Y+39);
//   ObjectSetInteger(lngG_ID,strG_LL1c_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+77); ObjectSetInteger(lngG_ID,strG_LL1c_Button_Nazwa,OBJPROP_YDISTANCE,intL_Y+57);
//   ObjectSetInteger(lngG_ID,strG_CAc_Button_Nazwa, OBJPROP_XDISTANCE,intL_X+77); ObjectSetInteger(lngG_ID,strG_CAc_Button_Nazwa, OBJPROP_YDISTANCE,intL_Y+75);
//   ObjectSetInteger(lngG_ID,strG_W15c_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+77); ObjectSetInteger(lngG_ID,strG_W15c_Button_Nazwa,OBJPROP_YDISTANCE,intL_Y+93);
//   //*****cena otwarcia*****
//   ObjectSetInteger(lngG_ID,strG_OP_Button_Nazwa,OBJPROP_XDISTANCE,intL_X);      ObjectSetInteger(lngG_ID,strG_OP_Button_Nazwa,OBJPROP_YDISTANCE,  intL_Y+112);
//   ObjectSetInteger(lngG_ID,strG_OPc_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+20);  ObjectSetInteger(lngG_ID,strG_OPc_Button_Nazwa,OBJPROP_YDISTANCE, intL_Y+112);
//   ObjectSetInteger(lngG_ID,strG_OPL_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+32);  ObjectSetInteger(lngG_ID,strG_OPL_Button_Nazwa,OBJPROP_YDISTANCE, intL_Y+112);
//   //*** W1:5 czyli W11
//   ObjectSetInteger(lngG_ID,strG_W11_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+48);  ObjectSetInteger(lngG_ID,strG_W11_Button_Nazwa,OBJPROP_YDISTANCE, intL_Y+111);
//   ObjectSetInteger(lngG_ID,strG_W11c_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+77);  ObjectSetInteger(lngG_ID,strG_W11c_Button_Nazwa,OBJPROP_YDISTANCE, intL_Y+111);
//   //*****SR Lines*****
//   ObjectSetInteger(lngG_ID,strG_SR_S_Button_Name,OBJPROP_XDISTANCE,intL_X+96);  ObjectSetInteger(lngG_ID,strG_SR_S_Button_Name,OBJPROP_YDISTANCE,intL_Y+101); 
//   ObjectSetInteger(lngG_ID,strG_SR_R_Button_Name,OBJPROP_XDISTANCE,intL_X+96);  ObjectSetInteger(lngG_ID,strG_SR_R_Button_Name,OBJPROP_YDISTANCE,intL_Y+117);
//   ObjectSetInteger(lngG_ID,strG_SR_D_Button_Name,OBJPROP_XDISTANCE,intL_X+96);  ObjectSetInteger(lngG_ID,strG_SR_D_Button_Name,OBJPROP_YDISTANCE,intL_Y+133);
//   //ELLIOTT (7/08/2018)
//   ObjectSetInteger(lngG_ID,strG_Elliott,OBJPROP_XDISTANCE,intL_X+96);           ObjectSetInteger(lngG_ID,strG_Elliott,OBJPROP_YDISTANCE,intL_Y-9);
//    
//   //***** trend lines ***** (18/06)
//   ObjectSetInteger(lngG_ID,strG_TL_1_Button_Name,OBJPROP_XDISTANCE,intL_X+96);  ObjectSetInteger(lngG_ID,strG_TL_1_Button_Name,OBJPROP_YDISTANCE,intL_Y+12); 
//   ObjectSetInteger(lngG_ID,strG_TL_2_Button_Name,OBJPROP_XDISTANCE,intL_X+96);  ObjectSetInteger(lngG_ID,strG_TL_2_Button_Name,OBJPROP_YDISTANCE,intL_Y+28); 
//   ObjectSetInteger(lngG_ID,strG_TL_d_Button_Name,OBJPROP_XDISTANCE,intL_X+96);  ObjectSetInteger(lngG_ID,strG_TL_d_Button_Name,OBJPROP_YDISTANCE,intL_Y+44); 
//
//   //kasuj wszystko
//   ObjectSetInteger(lngG_ID,strG_DA_Button_Nazwa,OBJPROP_XDISTANCE,intL_X);      ObjectSetInteger(lngG_ID,strG_DA_Button_Nazwa,OBJPROP_YDISTANCE,intL_Y+131); 
//   //ukryj wszystko - hide all
//   ObjectSetInteger(lngG_ID,strG_HA_Button_Nazwa,OBJPROP_XDISTANCE,intL_X+62);   ObjectSetInteger(lngG_ID,strG_HA_Button_Nazwa,OBJPROP_YDISTANCE,intL_Y+131);
//}
//+------------------------------------------------------------------+ 
bool move_Elliott_Up()
{
   //20180829
   bool blnL_return = false;
   int intL_ObjTotal=ObjectsTotal();
   string strL_Name; 
   for(int i=0;i<intL_ObjTotal;i++) 
   { 
      strL_Name = ObjectName(i);
      if(StringSubstr      (strL_Name,0,2) == "el")
      if(ObjectGetInteger  (lngG_ID,strL_Name,OBJPROP_SELECTED))
      {
         datetime dttL_Time = ObjectGetInteger(lngG_ID,strL_Name,OBJPROP_TIME);
         double   dlbL_Ptice = ObjectGetDouble (lngG_ID,strL_Name,OBJPROP_PRICE);  
         double dblL_Step = (WindowPriceMax() - WindowPriceMin())/10;
         //if(blnE_EllioTTonRSI) dblL_Step = 10;         
         ObjectMove(lngG_ID,strL_Name,0,dttL_Time,dlbL_Ptice + dblL_Step);
         blnL_return = true;
      }
   }
   return blnL_return;
}
//+------------------------------------------------------------------+ 
bool move_Elliott_Dn()
{
   //20180829
   bool blnL_return = false;   
   int intL_ObjTotal=ObjectsTotal(); 
   string strL_Name; 
   for(int i=0;i<intL_ObjTotal;i++) 
   { 
      strL_Name = ObjectName(i);
      if(StringSubstr      (strL_Name,0,2) == "el")
      if(ObjectGetInteger  (lngG_ID,strL_Name,OBJPROP_SELECTED))
      {
         datetime dttL_Time = ObjectGetInteger(lngG_ID,strL_Name,OBJPROP_TIME);
         double   dlbL_Ptice = ObjectGetDouble (lngG_ID,strL_Name,OBJPROP_PRICE);  
         double dblL_Step = (WindowPriceMax() - WindowPriceMin())/10;
         //if(blnE_EllioTTonRSI) dblL_Step = 10;
         ObjectMove(lngG_ID,strL_Name,0,dttL_Time,dlbL_Ptice - dblL_Step);
         blnL_return = true;
      }
   }
   return blnL_return; 
}
//+------------------------------------------------------------------+ 
//+               wczytywanie kolekcji                               +
//+------------------------------------------------------------------+
bool fill_Buttons_Collection()
{
//20180721 zmieniłem kolejność zeby byla zgodnosc z kolekcjami colors i letters itd

   col_Buttons[1]  = strG_BS_Button_Nazwa;   col_Buttons[11]  = strG_BSc_Button_Nazwa; col_Buttons[21]  = strG_BSh_Button_Nazwa; 
   col_Buttons[2]  = strG_LL_Button_Nazwa;   col_Buttons[12]  = strG_LLc_Button_Nazwa; col_Buttons[22]  = strG_LLh_Button_Nazwa; 
   col_Buttons[3]  = strG_RR_Button_Nazwa;   col_Buttons[13]  = strG_RRc_Button_Nazwa; col_Buttons[23]  = strG_RRh_Button_Nazwa; 
   col_Buttons[4]  = strG_CA_Button_Nazwa;   col_Buttons[14]  = strG_CAc_Button_Nazwa; col_Buttons[24]  = strG_CAh_Button_Nazwa; 
   col_Buttons[5]  = strG_W5_Button_Nazwa;   col_Buttons[15] = strG_W5c_Button_Nazwa;  col_Buttons[25]  = strG_W5h_Button_Nazwa; 
   col_Buttons[6]  = strG_LL1_Button_Nazwa;  col_Buttons[16] = strG_LL1c_Button_Nazwa; col_Buttons[26]  = strG_LL1h_Button_Nazwa; 
   col_Buttons[7]  = strG_RR1_Button_Nazwa;  col_Buttons[17] = strG_RR1c_Button_Nazwa; col_Buttons[27]  = strG_RR1h_Button_Nazwa; 
   col_Buttons[8]  = strG_W15_Button_Nazwa;  col_Buttons[18] = strG_W15c_Button_Nazwa; col_Buttons[28]  = strG_W15h_Button_Nazwa; 
   col_Buttons[9]  = strG_OP_Button_Nazwa;   col_Buttons[19] = strG_OPc_Button_Nazwa; 
   col_Buttons[10] = strG_W11_Button_Nazwa;  col_Buttons[20] = strG_W11c_Button_Nazwa; col_Buttons[30]  = strG_W11h_Button_Nazwa; 
   
   col_Buttons[31] = strG_DA_Button_Nazwa; 

   col_Buttons[32] = strG_Chart_Candles;
   col_Buttons[33] = strG_Chart_Bars;
   col_Buttons[34] = strG_Chart_Line;
   
   col_Buttons[35] = strG_Chart_SepLines;
   
   col_Buttons[36] = strG_Arrow_Up;
   col_Buttons[37] = strG_Arrow_Dn;
   //col_Buttons[28] = strG_Arrow_Lf;
   //col_Buttons[29] = strG_Arrow_Rt;
   
   col_Buttons[40] = strG_OPL_Button_Nazwa;
   col_Buttons[41] = strG_Shade_Title;//cieniowanie tytułu

   col_Buttons[42] = strG_Chart_Scale_Up;
   col_Buttons[43] = strG_Chart_Scale_Dn;
   col_Buttons[44] = strG_Chart_Scale_ST;
   col_Buttons[45] = strG_Chart_Scale_LT;

   col_Buttons[46] = strG_Chart_Shift;
   col_Buttons[47] = strG_Chart_AScroll;
   col_Buttons[48] = strG_Shade_Buttons;//cieniowanie buttonów
   
   col_Buttons[49] = strG_SR_S_Button_Name;
   col_Buttons[50] = strG_SR_R_Button_Name;
   //col_Buttons[41] = strG_SR_C_Button_Name;
   col_Buttons[52] = strG_SR_D_Button_Name;

   col_Buttons[53] = strG_TL_1_Button_Name;
   col_Buttons[54] = strG_TL_2_Button_Name;
   col_Buttons[55] = strG_TL_d_Button_Name;

   col_Buttons[56] = strG_HA_Button_Nazwa;
   
   col_Buttons[57] = strG_Elliott;
   
   col_Buttons[58] = strG_TL_Hide_Show_Button_Name;
   //col_Buttons[48] = strG_Label_Change;
   //col_Buttons[49] = strG_Shade_Change;

   //col_Buttons[50] = strG_Shade_Viper;
   //col_Buttons[51] = strG_Label_Viper;
   
   return true;   
}
//+------------------------------------------------------------------+
bool fill_Fibo_Collection()
{
   col_Fibo[1]  = strG_BS_Fibo_Nazwa;
   col_Fibo[2]  = strG_LL_Fibo_Nazwa;
   col_Fibo[3]  = strG_RR_Fibo_Nazwa;
   col_Fibo[4]  = strG_CA_Fibo_Nazwa;
   col_Fibo[5]  = strG_W5_Fibo_Nazwa;
   col_Fibo[6]  = strG_LL1_Fibo_Nazwa;
   col_Fibo[7]  = strG_RR1_Fibo_Nazwa;
   col_Fibo[8]  = strG_W15_Fibo_Nazwa;
   col_Fibo[9]  = strG_OP_Fibo_Nazwa;
   col_Fibo[10] = strG_W11_Fibo_Nazwa;
   return true;
}
////+------------------------------------------------------------------+
//bool fill_Fibo_Letters()
//{
//   //ArrayResize(col_Letters,11);
//   //Alert("Rozmiar kolekcji liter = ", ArraySize(col_Letters));
//   col_Letters[1]  = strG_BS_Fibo_Letters;//   Alert("i=",1,"element: ",col_Letters[1]);
//   col_Letters[2]  = strG_LL_Fibo_Letters;//   Alert("i=",2,"element: ",col_Letters[2]);
//   col_Letters[3]  = strG_RR_Fibo_Letters;//   Alert("i=",3,"element: ",col_Letters[3]);
//   col_Letters[4]  = strG_CA_Fibo_Letters;//   Alert("i=",4,"element: ",col_Letters[4]);
//   col_Letters[5]  = strG_W5_Fibo_Letters;//   Alert("i=",5,"element: ",col_Letters[5]);
//   col_Letters[6]  = strG_LL1_Fibo_Letters;//  Alert("i=",6,"element: ",col_Letters[6]);
//   col_Letters[7]  = strG_RR1_Fibo_Letters;//  Alert("i=",7,"element: ",col_Letters[7]);
//   col_Letters[8]  = strG_W15_Fibo_Letters;//  Alert("i=",8,"element: ",col_Letters[8]);
//   col_Letters[9]  = strG_OP_Fibo_Letters; //  Alert("i=",9,"element: ",col_Letters[9]);
//   col_Letters[10] = strG_W11_Fibo_Letters;//  Alert("i=",10,"element: ",col_Letters[10]);
//
//   //for(int i=0;i<=ArraySize(col_Letters)-1;i++)
//   //{
//   //  Alert("i=",i,"element: ",col_Letters[i]);      
//   //}
//   
//   return true;
//}
//+------------------------------------------------------------------+
bool fill_Fibo_Colors()
{
   col_Fibo_Colors[1]  = clrE_BS_Color;//strG_BS_Fibo_Nazwa;
   col_Fibo_Colors[2]  = clrE_LL_Color;//strG_LL_Fibo_Nazwa;
   col_Fibo_Colors[3]  = clrE_RR_Color;//strG_RR_Fibo_Nazwa;
   col_Fibo_Colors[4]  = clrE_CA_Color;//strG_CA_Fibo_Nazwa;
   col_Fibo_Colors[5]  = clrE_W5_Color;//strG_W5_Fibo_Nazwa;
   col_Fibo_Colors[6]  = clrE_LL1_Color;//strG_LL1_Fibo_Nazwa;
   col_Fibo_Colors[7]  = clrE_RR1_Color;//strG_RR1_Fibo_Nazwa;
   col_Fibo_Colors[8]  = clrE_W15_Color;//strG_W15_Fibo_Nazwa;
   col_Fibo_Colors[9]  = clrE_OP_Color;//strG_OP_Fibo_Nazwa;
   col_Fibo_Colors[10] = clrE_W11_Color;//strG_OP_Fibo_Nazwa;
   return true;   
}
//+------------------------------------------------------------------+
bool show_Fibo_On(string head_Fibo_Name)
{
   if(head_Fibo_Name!="*")
   {
      for(int i=1;i<26;i++)
      {
         string strL_Name = col_Fibo[i];
         if(head_Fibo_Name == strL_Name)
         {
            color clrL_Color = col_Fibo_Colors[i];
            ObjectSetInteger(lngG_ID,strL_Name,OBJPROP_LEVELCOLOR,clrL_Color);
            ObjectSetInteger(lngG_ID,strL_Name,OBJPROP_COLOR,clrL_Color); 
            break;
         }
      }
   }
   else
   {
      for(int i=1;i<26;i++)
      {
         string strL_Name = col_Fibo[i];
         color clrL_Color = col_Fibo_Colors[i];
         ObjectSetInteger(lngG_ID,strL_Name,OBJPROP_LEVELCOLOR,clrL_Color);
         ObjectSetInteger(lngG_ID,strL_Name,OBJPROP_COLOR,clrL_Color); 
      }
      //dodatek z 26/04/2019
      for(int i=0;i<ObjectsTotal(ChartID(),0,OBJ_EXPANSION);i++)
      {
         string strL_Name = ObjectName(ChartID(),i,0,OBJ_EXPANSION);
         if(ObjectGetInteger(lngG_ID,strL_Name,OBJPROP_COLOR) == clrNONE)
         {
            ObjectSetInteger(lngG_ID,strL_Name,OBJPROP_LEVELCOLOR,clrMoccasin);
            ObjectSetInteger(lngG_ID,strL_Name,OBJPROP_COLOR,clrMoccasin);
         }   
      }
      for(int i=0;i<ObjectsTotal(ChartID(),0,OBJ_FIBO);i++)
      {
         string strL_Name = ObjectName(ChartID(),i,0,OBJ_FIBO);
         if(ObjectGetInteger(lngG_ID,strL_Name,OBJPROP_COLOR) == clrNONE)
         {
            ObjectSetInteger(lngG_ID,strL_Name,OBJPROP_LEVELCOLOR,clrMoccasin);
            ObjectSetInteger(lngG_ID,strL_Name,OBJPROP_COLOR,clrMoccasin);
         }   
      }   
   }
   return true;
}
//+------------------------------------------------------------------+
bool show_Fibo_Off(string head_Fibo_Name)
{
   if(head_Fibo_Name!="*")
   {
      for(int i=1;i<26;i++)
      {
         string strL_Name = col_Fibo[i];
         if(head_Fibo_Name == strL_Name)
         {
            ObjectSetInteger(lngG_ID,strL_Name,OBJPROP_LEVELCOLOR,clrNONE);
            ObjectSetInteger(lngG_ID,strL_Name,OBJPROP_COLOR,clrNONE);
            ObjectSetInteger(lngG_ID,strL_Name,OBJPROP_SELECTED,false);
            break;         
         }
      }
   }
   else
   {
      for(int i=1;i<26;i++)
      {
         string strL_Name = col_Fibo[i];
         ObjectSetInteger(lngG_ID,strL_Name,OBJPROP_LEVELCOLOR,clrNONE);
         ObjectSetInteger(lngG_ID,strL_Name,OBJPROP_COLOR,clrNONE);
         ObjectSetInteger(lngG_ID,strL_Name,OBJPROP_SELECTED,false);
      }
      //dodatek z 26/04/2019
      for(int i=0;i<ObjectsTotal(ChartID(),0,OBJ_EXPANSION);i++)
      {
         string strL_Name = ObjectName(ChartID(),i,0,OBJ_EXPANSION);
         if(ObjectGetInteger(lngG_ID,strL_Name,OBJPROP_COLOR) != clrNONE)
         {
            ObjectSetInteger(lngG_ID,strL_Name,OBJPROP_LEVELCOLOR,clrNONE);
            ObjectSetInteger(lngG_ID,strL_Name,OBJPROP_COLOR,clrNONE);
            ObjectSetInteger(lngG_ID,strL_Name,OBJPROP_SELECTED,false);
         }   
      }
      for(int i=0;i<ObjectsTotal(ChartID(),0,OBJ_FIBO);i++)
      {
         string strL_Name = ObjectName(ChartID(),i,0,OBJ_FIBO);
         if(ObjectGetInteger(lngG_ID,strL_Name,OBJPROP_COLOR) != clrNONE)
         {
            ObjectSetInteger(lngG_ID,strL_Name,OBJPROP_LEVELCOLOR,clrNONE);
            ObjectSetInteger(lngG_ID,strL_Name,OBJPROP_COLOR,clrNONE);
            ObjectSetInteger(lngG_ID,strL_Name,OBJPROP_SELECTED,false);
         }   
      }
   }
   return true;
}
//+------------------------------------------------------------------+
//+               rysowanie geometrii                                +
//+------------------------------------------------------------------+
bool change_FiboSelectionState(string Fibo_Nazwa)
{
//20180306 przełącza między stanem aktywnym/pasynym objekt fibonacciego widoczny na ekranie
   //Alert(Fibo_Nazwa," ",ObjectFind(ChartID(),Fibo_Nazwa));
   if(ObjectFind(ChartID(),Fibo_Nazwa)!=-1)
   {
      if(ObjectGetInteger(ChartID(),Fibo_Nazwa,OBJPROP_SELECTED))
         ObjectSetInteger(ChartID(),Fibo_Nazwa,OBJPROP_SELECTED,false);
      else
         ObjectSetInteger(ChartID(),Fibo_Nazwa,OBJPROP_SELECTED,true);
      return false;
   }
   return true;
}
//+------------------------------------------------------------------+
bool add_BS()
{
   int intL_I0 = calc_I0();
   int intL_I1 = calc_I1();
   
   double dblL_P0 = calc_P0();
   double dblL_P1 = calc_P1();

   create_Fibo_Ret(ChartID(),strG_BS_Fibo_Nazwa,0,Time[intL_I0],dblL_P1,Time[intL_I1],dblL_P0,clrE_BS_Color);

   //ustawienia BS
   ObjectSetInteger  (ChartID(),strG_BS_Fibo_Nazwa,OBJPROP_LEVELS,4);
   ObjectSetInteger  (ChartID(),strG_BS_Fibo_Nazwa,OBJPROP_LEVELCOLOR,clrE_BS_Color);
   ObjectSetInteger  (ChartID(),strG_BS_Fibo_Nazwa,OBJPROP_LEVELSTYLE,inp_BS_Style);
   ObjectSetInteger  (ChartID(),strG_BS_Fibo_Nazwa,OBJPROP_LEVELWIDTH,1);

   ObjectSetDouble   (ChartID(),strG_BS_Fibo_Nazwa,OBJPROP_LEVELVALUE,0,0.000);
   //ObjectSetDouble   (ChartID(),strG_BS_Fibo_Nazwa,OBJPROP_LEVELVALUE,1,0.300);
   ObjectSetDouble   (ChartID(),strG_BS_Fibo_Nazwa,OBJPROP_LEVELVALUE,1,0.382);
   ObjectSetDouble   (ChartID(),strG_BS_Fibo_Nazwa,OBJPROP_LEVELVALUE,2,0.431);
   ObjectSetDouble   (ChartID(),strG_BS_Fibo_Nazwa,OBJPROP_LEVELVALUE,3,1.000);

   ObjectSetString   (ChartID(),strG_BS_Fibo_Nazwa,OBJPROP_LEVELTEXT,0,"BS 0.0 (%$)"); 
   //ObjectSetString   (ChartID(),strG_BS_Fibo_Nazwa,OBJPROP_LEVELTEXT,1,"BS 30.0 (%$)"); 
   ObjectSetString   (ChartID(),strG_BS_Fibo_Nazwa,OBJPROP_LEVELTEXT,1,"BS 38.2 (%$)"); 
   ObjectSetString   (ChartID(),strG_BS_Fibo_Nazwa,OBJPROP_LEVELTEXT,2,"Max Grand Trend Stop BS (%$)"); 
   ObjectSetString   (ChartID(),strG_BS_Fibo_Nazwa,OBJPROP_LEVELTEXT,3,"BS 100.0 (%$)"); 

   return true;
}
//+------------------------------------------------------------------+
bool add_LL()
{
//20170208
   int intL_I0 = calc_I0();
   int intL_I1 = calc_I1();
   
   double dblL_P0 = calc_P0();
   double dblL_P1 = calc_P1();

   create_Fibo_Ret(ChartID(),strG_LL_Fibo_Nazwa,0,Time[intL_I0],dblL_P1,Time[intL_I1],dblL_P0,clrE_LL_Color);

   ObjectSetInteger  (ChartID(),strG_LL_Fibo_Nazwa,OBJPROP_LEVELS,7); 
   ObjectSetInteger  (ChartID(),strG_LL_Fibo_Nazwa,OBJPROP_LEVELCOLOR,clrE_LL_Color); 
   ObjectSetInteger  (ChartID(),strG_LL_Fibo_Nazwa,OBJPROP_LEVELSTYLE,inp_LL_Style); 
   ObjectSetInteger  (ChartID(),strG_LL_Fibo_Nazwa,OBJPROP_LEVELWIDTH,1); 

   ObjectSetDouble   (ChartID(),strG_LL_Fibo_Nazwa,OBJPROP_LEVELVALUE,0,0.000);
   ObjectSetDouble   (ChartID(),strG_LL_Fibo_Nazwa,OBJPROP_LEVELVALUE,1,0.300);   
   ObjectSetDouble   (ChartID(),strG_LL_Fibo_Nazwa,OBJPROP_LEVELVALUE,2,0.382);
   ObjectSetDouble   (ChartID(),strG_LL_Fibo_Nazwa,OBJPROP_LEVELVALUE,3,0.486);
   ObjectSetDouble   (ChartID(),strG_LL_Fibo_Nazwa,OBJPROP_LEVELVALUE,4,0.618);
   ObjectSetDouble   (ChartID(),strG_LL_Fibo_Nazwa,OBJPROP_LEVELVALUE,5,0.786);
   ObjectSetDouble   (ChartID(),strG_LL_Fibo_Nazwa,OBJPROP_LEVELVALUE,6,1.000);

   ObjectSetString   (ChartID(),strG_LL_Fibo_Nazwa,OBJPROP_LEVELTEXT,0,"LL 0.0 (%$)");
   ObjectSetString   (ChartID(),strG_LL_Fibo_Nazwa,OBJPROP_LEVELTEXT,1,"LL 30.0 (%$)");    
   ObjectSetString   (ChartID(),strG_LL_Fibo_Nazwa,OBJPROP_LEVELTEXT,2,"LL 38.2 (%$)"); 
   ObjectSetString   (ChartID(),strG_LL_Fibo_Nazwa,OBJPROP_LEVELTEXT,3,"LL 48.6 (%$)"); 
   ObjectSetString   (ChartID(),strG_LL_Fibo_Nazwa,OBJPROP_LEVELTEXT,4,"LL 61.8 (%$)"); 
   ObjectSetString   (ChartID(),strG_LL_Fibo_Nazwa,OBJPROP_LEVELTEXT,5,"LL 78.6 (%$)");
   ObjectSetString   (ChartID(),strG_LL_Fibo_Nazwa,OBJPROP_LEVELTEXT,6,"LL 100.0 (%$)");   
   return true;
}
////+------------------------------------------------------------------+
////+                   opisy geometrii                                +
////+------------------------------------------------------------------+
//bool manage_Fibo_Letters(const bool head_show = true)
//{
////20180721
//   if(!head_show)
//   {
//      //Alert("Kasuje");
//      //delete_All_Letters();
//      return false;
//   }
//
//   for(int i=0;i<=25;i++)
//   {
//      string strL_Fibo_Nazwa = col_Fibo[i];
//      if(ObjectFind(ChartID(),strL_Fibo_Nazwa)!=-1)
//      {
//         if(!ObjectGetInteger(ChartID(),strL_Fibo_Nazwa,OBJPROP_SELECTED))
//         {
//            datetime dttL_P0  = ObjectGetInteger(lngG_ID,strL_Fibo_Nazwa,OBJPROP_TIME,0);
//            double   dblL_P0  = ObjectGetDouble (lngG_ID,strL_Fibo_Nazwa,OBJPROP_PRICE,0);
//            double   dblL_P1  = ObjectGetDouble (lngG_ID,strL_Fibo_Nazwa,OBJPROP_PRICE,1);
//            
//            ENUM_ANCHOR_POINT enmL_Anchor;
//            
//            if(dblL_P0>dblL_P1)  enmL_Anchor = ANCHOR_LEFT_LOWER;
//            else                 enmL_Anchor = ANCHOR_LEFT_UPPER;
//   
//            create_Text(lngG_ID,col_Letters[i],0,dttL_P0,dblL_P0,col_Letters[i],"Arial Black",10,col_Fibo_Colors[i],0,enmL_Anchor);  
//         }
//         else
//            ObjectDelete(lngG_ID,col_Letters[i]);
//         return false;
//      }
//   }
//   return true;
//}
//+------------------------------------------------------------------+
bool add_LL1()
{
//20170208
   int intL_I0 = calc_I0();
   int intL_I1 = calc_I1();
   
   double dblL_P0 = calc_P0();
   double dblL_P1 = calc_P1();

   create_Fibo_Ret(ChartID(),strG_LL1_Fibo_Nazwa,0,Time[intL_I0],dblL_P1,Time[intL_I1],dblL_P0,clrE_LL1_Color);

   ObjectSetInteger  (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELS,12); 
   ObjectSetInteger  (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELCOLOR,clrE_LL1_Color); 
   ObjectSetInteger  (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELSTYLE,stlE_LL1_Style); 
   ObjectSetInteger  (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELWIDTH,1); 

   ObjectSetDouble   (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELVALUE,0,0.000);
   ObjectSetDouble   (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELVALUE,1,0.300);   
   ObjectSetDouble   (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELVALUE,2,0.339);
   ObjectSetDouble   (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELVALUE,3,0.382);
   ObjectSetDouble   (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELVALUE,4,0.431);
   ObjectSetDouble   (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELVALUE,5,0.486);
   ObjectSetDouble   (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELVALUE,6,0.548);
   ObjectSetDouble   (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELVALUE,7,0.618);
   ObjectSetDouble   (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELVALUE,8,0.697);
   ObjectSetDouble   (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELVALUE,9,0.786);
   ObjectSetDouble   (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELVALUE,10,0.887);
   ObjectSetDouble   (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELVALUE,11,1.000);

   ObjectSetString   (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELTEXT,0,"LL1 0.0 (%$)");
   ObjectSetString   (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELTEXT,1,"LL1 30.0 (%$)");   
   ObjectSetString   (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELTEXT,2,"LL1 33.9 (%$)");   
   ObjectSetString   (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELTEXT,3,"LL1 38.2 (%$)");
   ObjectSetString   (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELTEXT,4,"LL1 43.1 (%$)");
   ObjectSetString   (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELTEXT,5,"LL1 48.6 (%$)");
   ObjectSetString   (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELTEXT,6,"LL1 54.8 (%$)");
   ObjectSetString   (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELTEXT,7,"LL1 61.8 (%$)");
   ObjectSetString   (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELTEXT,8,"LL1 69.7 (%$)");
   ObjectSetString   (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELTEXT,9,"LL1 78.6 (%$)");
   ObjectSetString   (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELTEXT,10,"LL1 88.7 (%$)");
   ObjectSetString   (ChartID(),strG_LL1_Fibo_Nazwa,OBJPROP_LEVELTEXT,11,"LL1 100.0 (%$)");
   return true;
}
//+------------------------------------------------------------------+
bool add_RR()
{
   int intL_I0 = calc_I0();
   int intL_I1 = calc_I1();
   int intL_I2 = calc_I2();
   
   double dblL_P0 = calc_P0();
   double dblL_P1 = calc_P1();
   double dblL_P2 = calc_P2();
   
   create_Fibo_Exp(ChartID(),strG_RR_Fibo_Nazwa,0,Time[intL_I0],dblL_P0,Time[intL_I1],dblL_P1, Time[intL_I2],dblL_P2,clrE_RR_Color);

   ObjectSetInteger  (ChartID(),strG_RR_Fibo_Nazwa,OBJPROP_LEVELS,4); 
   ObjectSetInteger  (ChartID(),strG_RR_Fibo_Nazwa,OBJPROP_LEVELCOLOR,clrE_RR_Color); 
   ObjectSetInteger  (ChartID(),strG_RR_Fibo_Nazwa,OBJPROP_LEVELSTYLE,inp_RR_Style); 
   ObjectSetInteger  (ChartID(),strG_RR_Fibo_Nazwa,OBJPROP_LEVELWIDTH,1); 

   ObjectSetDouble   (ChartID(),strG_RR_Fibo_Nazwa,OBJPROP_LEVELVALUE,0,0.786);
   ObjectSetDouble   (ChartID(),strG_RR_Fibo_Nazwa,OBJPROP_LEVELVALUE,1,1.000);
   ObjectSetDouble   (ChartID(),strG_RR_Fibo_Nazwa,OBJPROP_LEVELVALUE,2,1.272);
   ObjectSetDouble   (ChartID(),strG_RR_Fibo_Nazwa,OBJPROP_LEVELVALUE,3,1.618);
   
   ObjectSetString   (ChartID(),strG_RR_Fibo_Nazwa,OBJPROP_LEVELTEXT,0,"RR 78.6 (%$)");
   ObjectSetString   (ChartID(),strG_RR_Fibo_Nazwa,OBJPROP_LEVELTEXT,1,"RR 100.0 (%$)");
   ObjectSetString   (ChartID(),strG_RR_Fibo_Nazwa,OBJPROP_LEVELTEXT,2,"RR 127.2 (%$)");
   ObjectSetString   (ChartID(),strG_RR_Fibo_Nazwa,OBJPROP_LEVELTEXT,3,"RR 161.8 (%$)");
   return true;
}
//+------------------------------------------------------------------+
bool add_RR1()
{
   int intL_I0 = calc_I0();
   int intL_I1 = calc_I1();
   int intL_I2 = calc_I2();;
   
   double dblL_P0 = calc_P0();
   double dblL_P1 = calc_P1();
   double dblL_P2 = calc_P2();

   create_Fibo_Exp(ChartID(),strG_RR1_Fibo_Nazwa,0,Time[intL_I0],dblL_P0,Time[intL_I1],dblL_P1, Time[intL_I2],dblL_P2,clrE_RR1_Color);

   ObjectSetInteger  (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELS,7); 
   ObjectSetInteger  (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELCOLOR,clrE_RR1_Color); 
   ObjectSetInteger  (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELSTYLE,stlE_RR1_Style); 
   ObjectSetInteger  (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELWIDTH,intE_RR1_Width); 

   ObjectSetDouble   (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELVALUE,0,0.618);
   ObjectSetDouble   (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELVALUE,1,0.786);
   ObjectSetDouble   (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELVALUE,2,1.000);
   ObjectSetDouble   (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELVALUE,3,1.272);
   ObjectSetDouble   (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELVALUE,4,1.618);
   ObjectSetDouble   (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELVALUE,5,2.058);
   ObjectSetDouble   (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELVALUE,6,2.618);

//   ObjectSetDouble   (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELVALUE,7,0.382);
//   ObjectSetDouble   (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELVALUE,8,-0.382);
//   ObjectSetDouble   (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELVALUE,9,-0.486);
//   ObjectSetDouble   (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELVALUE,10,-0.618);
//   ObjectSetDouble   (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELVALUE,12,-0.786);
//   ObjectSetDouble   (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELVALUE,13,-1.000);
//   ObjectSetDouble   (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELVALUE,14,-1.272);
//   ObjectSetDouble   (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELVALUE,15,-1.618);
//
//
   ObjectSetString   (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELTEXT,0,"Rev Max T 61.8 (%$)");     
   ObjectSetString   (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELTEXT,1,"RR1 78.6 (%$)");
   ObjectSetString   (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELTEXT,2,"RR1 100.0 (%$)");
   ObjectSetString   (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELTEXT,3,"Basic Trend Stop 127.2 (%$)");
   ObjectSetString   (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELTEXT,4,"Broad Trend Stop 161.8 (%$)");
   ObjectSetString   (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELTEXT,5,"Max Trend Stop 205.8 (%$)");
   ObjectSetString   (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELTEXT,6,"Mad Max 261.8 (%$)");
   //ObjectSetString   (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELTEXT,7,"--- 333.0 (%$)");
   //ObjectSetString   (ChartID(),strG_RR1_Fibo_Nazwa,OBJPROP_LEVELTEXT,8,"--- 423.6 (%$)");

   return true;
}
////+------------------------------------------------------------------+
//bool manage_RR1()
//{
//   if(!ObjectFind(lngG_ID,strG_RR1_Fibo_Nazwa)) return false;
//   //Alert("Objekt ",strG_RR1_Fibo_Nazwa," istnieje");
//   
//   double dblL_price2  = ObjectGetDouble(lngG_ID,strG_RR1_Fibo_Nazwa,OBJPROP_PRICE2);
//   double dblL_price3  = ObjectGetDouble(lngG_ID,strG_RR1_Fibo_Nazwa,OBJPROP_PRICE3);//   Alert("Price3 = ",dblL_price3);
//
//   datetime dttL_time3 = ObjectGet(strG_RR1_Fibo_Nazwa,OBJPROP_TIME3);// Alert("Time3 = ",dttL_time3);
//   int      dblL_i3   = iBarShift(NULL,0,dttL_time3);
//   
//   int      intL_LL = iLowest(NULL,0,MODE_LOW,5,0);
//   int      intL_HH = iLowest(NULL,0,MODE_HIGH,5,0);
//   double   dblL_price_LL = Low[intL_LL];
//   double   dblL_price_HH = Low[intL_HH];
//
//   if(dblL_price3 < dblL_price2)  
//   {   
//      if(dblL_i3 >=5)
//      if(dblL_price3 > dblL_price_LL)
//      {
//         ObjectSetDouble(lngG_ID,strG_RR1_Fibo_Nazwa,OBJPROP_PRICE3,dblL_price_LL);
//         ObjectSet(strG_RR1_Fibo_Nazwa,OBJPROP_TIME3,Time[intL_LL]);
//      }
//   }
//   else
//   {
//      if(dblL_i3 >=5)
//      if(dblL_price3 < dblL_price_HH)
//      {
//         ObjectSetDouble(lngG_ID,strG_RR1_Fibo_Nazwa,OBJPROP_PRICE3,dblL_price_HH);
//         ObjectSet(strG_RR1_Fibo_Nazwa,OBJPROP_TIME3,Time[intL_HH]);
//      }
//   }
//   
//   return true;
//}
//+------------------------------------------------------------------+
bool add_C_A()
{
   int intL_I0 = calc_I0();
   int intL_I1 = calc_I1();
   int intL_I2 = calc_I2();;
   
   double dblL_P0 = calc_P0();
   double dblL_P1 = calc_P1();
   double dblL_P2 = calc_P2();

   create_Fibo_Exp(ChartID(),strG_CA_Fibo_Nazwa,0,Time[intL_I0],dblL_P0,Time[intL_I1],dblL_P1, Time[intL_I2],dblL_P2,clrE_CA_Color);

   ObjectSetInteger  (ChartID(),strG_CA_Fibo_Nazwa,OBJPROP_LEVELS,6); 
   ObjectSetInteger  (ChartID(),strG_CA_Fibo_Nazwa,OBJPROP_LEVELCOLOR,clrE_CA_Color); 
   ObjectSetInteger  (ChartID(),strG_CA_Fibo_Nazwa,OBJPROP_LEVELSTYLE,STYLE_DOT); 
   ObjectSetInteger  (ChartID(),strG_CA_Fibo_Nazwa,OBJPROP_LEVELWIDTH,1); 

   ObjectSetDouble   (ChartID(),strG_CA_Fibo_Nazwa,OBJPROP_LEVELVALUE,0,0.618);
   ObjectSetDouble   (ChartID(),strG_CA_Fibo_Nazwa,OBJPROP_LEVELVALUE,1,0.786);      
   ObjectSetDouble   (ChartID(),strG_CA_Fibo_Nazwa,OBJPROP_LEVELVALUE,2,1.000);
   ObjectSetDouble   (ChartID(),strG_CA_Fibo_Nazwa,OBJPROP_LEVELVALUE,3,1.272);
   ObjectSetDouble   (ChartID(),strG_CA_Fibo_Nazwa,OBJPROP_LEVELVALUE,4,1.618);
   ObjectSetDouble   (ChartID(),strG_CA_Fibo_Nazwa,OBJPROP_LEVELVALUE,5,2.058);

   ObjectSetString   (ChartID(),strG_CA_Fibo_Nazwa,OBJPROP_LEVELTEXT,0,"C:A 61.8 (%$)");    
   ObjectSetString   (ChartID(),strG_CA_Fibo_Nazwa,OBJPROP_LEVELTEXT,1,"C:A 78.6 (%$)");
   ObjectSetString   (ChartID(),strG_CA_Fibo_Nazwa,OBJPROP_LEVELTEXT,2,"C:A 100.0 (%$)");
   ObjectSetString   (ChartID(),strG_CA_Fibo_Nazwa,OBJPROP_LEVELTEXT,3,"C:A 127.2 (%$)");
   ObjectSetString   (ChartID(),strG_CA_Fibo_Nazwa,OBJPROP_LEVELTEXT,4,"C:A 161.8 (%$)");
   ObjectSetString   (ChartID(),strG_CA_Fibo_Nazwa,OBJPROP_LEVELTEXT,5,"C:A 205.8 (%$)");
         
   return true;
}
//+------------------------------------------------------------------+
bool add_W5()
{
//20170208
   int intL_I0 = calc_I0();
   int intL_I1 = calc_I1();

   double dblL_P0 = calc_P0();
   double dblL_P1 = calc_P1();

   create_Fibo_Ret(ChartID(),strG_W5_Fibo_Nazwa,0,Time[intL_I0],dblL_P0,Time[intL_I1],dblL_P1,clrE_W5_Color);

   ObjectSetInteger  (ChartID(),strG_W5_Fibo_Nazwa,OBJPROP_LEVELS,8); 
   ObjectSetInteger  (ChartID(),strG_W5_Fibo_Nazwa,OBJPROP_LEVELCOLOR,clrE_W5_Color); 
   ObjectSetInteger  (ChartID(),strG_W5_Fibo_Nazwa,OBJPROP_LEVELSTYLE,inp_W5_Style); 
   ObjectSetInteger  (ChartID(),strG_W5_Fibo_Nazwa,OBJPROP_LEVELWIDTH,1); 

   ObjectSetDouble   (ChartID(),strG_W5_Fibo_Nazwa,OBJPROP_LEVELVALUE,0,0.000);
   ObjectSetDouble   (ChartID(),strG_W5_Fibo_Nazwa,OBJPROP_LEVELVALUE,1,1.000);
   ObjectSetDouble   (ChartID(),strG_W5_Fibo_Nazwa,OBJPROP_LEVELVALUE,2,1.272);
   ObjectSetDouble   (ChartID(),strG_W5_Fibo_Nazwa,OBJPROP_LEVELVALUE,3,1.618);
   ObjectSetDouble   (ChartID(),strG_W5_Fibo_Nazwa,OBJPROP_LEVELVALUE,4,2.058);
   ObjectSetDouble   (ChartID(),strG_W5_Fibo_Nazwa,OBJPROP_LEVELVALUE,5,2.618);
   ObjectSetDouble   (ChartID(),strG_W5_Fibo_Nazwa,OBJPROP_LEVELVALUE,6,3.330);
   ObjectSetDouble   (ChartID(),strG_W5_Fibo_Nazwa,OBJPROP_LEVELVALUE,7,4.236);
   
   ObjectSetString   (ChartID(),strG_W5_Fibo_Nazwa,OBJPROP_LEVELTEXT,0,"W5 0.0 (%$)"); 
   ObjectSetString   (ChartID(),strG_W5_Fibo_Nazwa,OBJPROP_LEVELTEXT,1,"W5 100.0 (%$)"); 
   ObjectSetString   (ChartID(),strG_W5_Fibo_Nazwa,OBJPROP_LEVELTEXT,2,"W5 127.2 (%$)");   
   ObjectSetString   (ChartID(),strG_W5_Fibo_Nazwa,OBJPROP_LEVELTEXT,3,"W5 161.8 (%$)");; 
   ObjectSetString   (ChartID(),strG_W5_Fibo_Nazwa,OBJPROP_LEVELTEXT,4,"W5 205.8 (%$)"); 
   ObjectSetString   (ChartID(),strG_W5_Fibo_Nazwa,OBJPROP_LEVELTEXT,5,"W5 261.8 (%$)");       
   ObjectSetString   (ChartID(),strG_W5_Fibo_Nazwa,OBJPROP_LEVELTEXT,6,"W5 333.0 (%$)");       
   ObjectSetString   (ChartID(),strG_W5_Fibo_Nazwa,OBJPROP_LEVELTEXT,7,"W5 423.6 (%$)");       

   return true;
}
//+------------------------------------------------------------------+
bool add_OP()
{
//20170518
   string strL_Nazwa = strG_OP_Fibo_Nazwa;
   int      intL_I1;
   double   dblL_P1;
   
   if(ObjectGetInteger(lngG_ID,strG_OPL_Button_Nazwa,OBJPROP_STATE))
   {
      datetime dttL_OP_T = ObjectGetInteger(lngG_ID,strG_OP_Line,OBJPROP_TIME1);
      double   dblL_OP_V = ObjectGetDouble (lngG_ID,strG_OP_Line,OBJPROP_PRICE1);
      int      intL_OP_I = calc_OpenPrice_I_TTF();
      
      int intL_I_HH = iHighest(NULL,0,MODE_HIGH,intL_OP_I,0);
      int intL_I_LL = iLowest (NULL,0,MODE_LOW, intL_OP_I,0);
      
      //viększy vażniejszy
      double dblL_Gain = High[intL_I_HH] - Close[intL_OP_I], dblL_Loss = Close[intL_OP_I] - Low[intL_I_LL];     
      if(dblL_Gain>dblL_Loss) { intL_I1 = intL_I_HH;  dblL_P1 = High[intL_I1];}
      else                    { intL_I1 = intL_I_LL;  dblL_P1 = Low[intL_I1]; }
      
      create_Fibo_Ret(ChartID(),strL_Nazwa,0,dttL_OP_T,dblL_OP_V,Time[intL_I1],dblL_P1,clrE_OP_Color);      
   }
   else
   {
      int      intL_I0 = calc_I0();
      double   dblL_P0 = calc_P0();
               intL_I1 = calc_I1();
               dblL_P1 = calc_P1();
      
      create_Fibo_Ret(ChartID(),strL_Nazwa,0,Time[intL_I0],dblL_P0,Time[intL_I1],dblL_P1,clrE_OP_Color);      
   }
   
   ObjectSetInteger  (ChartID(),strL_Nazwa,OBJPROP_LEVELS,16); 
   ObjectSetInteger  (ChartID(),strL_Nazwa,OBJPROP_LEVELCOLOR,clrE_OP_Color); 
   ObjectSetInteger  (ChartID(),strL_Nazwa,OBJPROP_LEVELSTYLE,stlE_OP_Style); 
   ObjectSetInteger  (ChartID(),strL_Nazwa,OBJPROP_LEVELWIDTH,1); 

   ObjectSetDouble   (ChartID(),strL_Nazwa,OBJPROP_LEVELVALUE,0,0.000);
   ObjectSetDouble   (ChartID(),strL_Nazwa,OBJPROP_LEVELVALUE,1,0.618);
   ObjectSetDouble   (ChartID(),strL_Nazwa,OBJPROP_LEVELVALUE,2,0.786);
   ObjectSetDouble   (ChartID(),strL_Nazwa,OBJPROP_LEVELVALUE,3,1.000);
   ObjectSetDouble   (ChartID(),strL_Nazwa,OBJPROP_LEVELVALUE,4,1.272);
   ObjectSetDouble   (ChartID(),strL_Nazwa,OBJPROP_LEVELVALUE,5,1.618);
   ObjectSetDouble   (ChartID(),strL_Nazwa,OBJPROP_LEVELVALUE,6,2.058);
   ObjectSetDouble   (ChartID(),strL_Nazwa,OBJPROP_LEVELVALUE,7,2.618);
   ObjectSetDouble   (ChartID(),strL_Nazwa,OBJPROP_LEVELVALUE,8,3.330);
   ObjectSetDouble   (ChartID(),strL_Nazwa,OBJPROP_LEVELVALUE,9,4.236);
   ObjectSetDouble   (ChartID(),strL_Nazwa,OBJPROP_LEVELVALUE,10,5.389);
   ObjectSetDouble   (ChartID(),strL_Nazwa,OBJPROP_LEVELVALUE,11,6.856);
   ObjectSetDouble   (ChartID(),strL_Nazwa,OBJPROP_LEVELVALUE,12,8.721);
   ObjectSetDouble   (ChartID(),strL_Nazwa,OBJPROP_LEVELVALUE,13,0.382);
   ObjectSetDouble   (ChartID(),strL_Nazwa,OBJPROP_LEVELVALUE,14,0.486);
   ObjectSetDouble   (ChartID(),strL_Nazwa,OBJPROP_LEVELVALUE,15,0.887);

   ObjectSetString   (ChartID(),strL_Nazwa,OBJPROP_LEVELTEXT,0,"OP 0.0 (%$)"); 
   ObjectSetString   (ChartID(),strL_Nazwa,OBJPROP_LEVELTEXT,1,"OP 0.618 (%$)");   
   ObjectSetString   (ChartID(),strL_Nazwa,OBJPROP_LEVELTEXT,2,"OP 0.786 (%$)");   
   ObjectSetString   (ChartID(),strL_Nazwa,OBJPROP_LEVELTEXT,3,"OP 1.000 (%$)");   
   ObjectSetString   (ChartID(),strL_Nazwa,OBJPROP_LEVELTEXT,4,"OP 127.2 (%$)");   
   ObjectSetString   (ChartID(),strL_Nazwa,OBJPROP_LEVELTEXT,5,"OP 161.8 (%$)");; 
   ObjectSetString   (ChartID(),strL_Nazwa,OBJPROP_LEVELTEXT,6,"OP 205.8 (%$)"); 
   ObjectSetString   (ChartID(),strL_Nazwa,OBJPROP_LEVELTEXT,7,"OP 261.8 (%$)");       
   ObjectSetString   (ChartID(),strL_Nazwa,OBJPROP_LEVELTEXT,8,"OP 333.0 (%$)");       
   ObjectSetString   (ChartID(),strL_Nazwa,OBJPROP_LEVELTEXT,9,"OP 423.6 (%$)");       
   ObjectSetString   (ChartID(),strL_Nazwa,OBJPROP_LEVELTEXT,10,"OP 538.9 (%$)");       
   ObjectSetString   (ChartID(),strL_Nazwa,OBJPROP_LEVELTEXT,11,"OP 685.6 (%$)");       
   ObjectSetString   (ChartID(),strL_Nazwa,OBJPROP_LEVELTEXT,12,"OP 872.1 (%$)");       
   ObjectSetString   (ChartID(),strL_Nazwa,OBJPROP_LEVELTEXT,13,"OP 0.382 (%$)");       
   ObjectSetString   (ChartID(),strL_Nazwa,OBJPROP_LEVELTEXT,14,"OP 0.486 (%$)");       
   ObjectSetString   (ChartID(),strL_Nazwa,OBJPROP_LEVELTEXT,15,"OP 0.887 (%$)");       

   return true;
}
//+------------------------------------------------------------------+
bool add_W11x5()
{
//20170208
   int intL_I0 = calc_I0();
   int intL_I1 = calc_I1();

   double dblL_P0 = calc_P0();
   double dblL_P1 = calc_P1();

   create_Fibo_Ret(ChartID(),strG_W11_Fibo_Nazwa,0,Time[intL_I0],dblL_P0,Time[intL_I1],dblL_P1,clrE_W11_Color);

   string strL_Geo = strG_W11_Fibo_Nazwa;
   
   ObjectSetInteger  (ChartID(),strL_Geo,OBJPROP_LEVELS,8); 
   ObjectSetInteger  (ChartID(),strL_Geo,OBJPROP_LEVELCOLOR,clrE_W11_Color); 
   ObjectSetInteger  (ChartID(),strL_Geo,OBJPROP_LEVELSTYLE,stlE_W11_Style); 
   ObjectSetInteger  (ChartID(),strL_Geo,OBJPROP_LEVELWIDTH,1);
   
   ObjectSetDouble   (ChartID(),strL_Geo,OBJPROP_LEVELVALUE,0,0.000);
   ObjectSetDouble   (ChartID(),strL_Geo,OBJPROP_LEVELVALUE,1,1.000);
   ObjectSetDouble   (ChartID(),strL_Geo,OBJPROP_LEVELVALUE,2,-0.272);
   ObjectSetDouble   (ChartID(),strL_Geo,OBJPROP_LEVELVALUE,3,-0.618);
   ObjectSetDouble   (ChartID(),strL_Geo,OBJPROP_LEVELVALUE,4,-1.058);
   ObjectSetDouble   (ChartID(),strL_Geo,OBJPROP_LEVELVALUE,5,-1.618);
   ObjectSetDouble   (ChartID(),strL_Geo,OBJPROP_LEVELVALUE,6,-2.330);
   ObjectSetDouble   (ChartID(),strL_Geo,OBJPROP_LEVELVALUE,7,-3.236);
   
   ObjectSetString   (ChartID(),strL_Geo,OBJPROP_LEVELTEXT,0,"W1 0.0 (%$)"); 
   ObjectSetString   (ChartID(),strL_Geo,OBJPROP_LEVELTEXT,1,"W1 100.0 (%$)"); 
   ObjectSetString   (ChartID(),strL_Geo,OBJPROP_LEVELTEXT,2,"W1 127.2 (%$)");   
   ObjectSetString   (ChartID(),strL_Geo,OBJPROP_LEVELTEXT,3,"W1 161.8 (%$)");; 
   ObjectSetString   (ChartID(),strL_Geo,OBJPROP_LEVELTEXT,4,"W1 205.8 (%$)"); 
   ObjectSetString   (ChartID(),strL_Geo,OBJPROP_LEVELTEXT,5,"W1 261.8 (%$)");       
   ObjectSetString   (ChartID(),strL_Geo,OBJPROP_LEVELTEXT,6,"W1 333.0 (%$)");       
   ObjectSetString   (ChartID(),strL_Geo,OBJPROP_LEVELTEXT,7,"W1 423.6 (%$)");       

   return true;
}
////+------------------------------------------------------------------+
void add_Waves()
{
   //20180808-20180902
   
   //---pozycje pion   
   double dlbL_Gdzie_1;
   double dlbL_Gdzie_2;
   double dlbL_Gdzie_3;
   double dlbL_Gdzie_4;
   double dlbL_Gdzie_5;
   double dlbL_Gdzie_6;
   double dlbL_Gdzie_7;

   double dblL_price_min   = WindowPriceMin(0);
   double dblL_price_range = WindowPriceMax(0) - dblL_price_min;
   double dblL_price_mid   = .6* dblL_price_range + dblL_price_min;

   double dblL_idx_base;
   double dblL_idx_step;

   int intL_Bar_First   = WindowFirstVisibleBar() - WindowBarsPerChart() * 0.9;   if(intL_Bar_First <0) intL_Bar_First = 0;
 
   if(Close[intL_Bar_First]<dblL_price_mid)
   {
      dblL_idx_base    = .95;
      dblL_idx_step    = -.05;     
      dlbL_Gdzie_1 = (dblL_idx_base + 0*dblL_idx_step) * dblL_price_range + dblL_price_min;
      dlbL_Gdzie_2 = (dblL_idx_base + 1*dblL_idx_step) * dblL_price_range + dblL_price_min;
      dlbL_Gdzie_3 = (dblL_idx_base + 2*dblL_idx_step) * dblL_price_range + dblL_price_min;
      dlbL_Gdzie_4 = (dblL_idx_base + 3*dblL_idx_step) * dblL_price_range + dblL_price_min;
      dlbL_Gdzie_5 = (dblL_idx_base + 4*dblL_idx_step) * dblL_price_range + dblL_price_min;
      dlbL_Gdzie_6 = (dblL_idx_base + 5*dblL_idx_step) * dblL_price_range + dblL_price_min;
      dlbL_Gdzie_7 = (dblL_idx_base + 7*dblL_idx_step) * dblL_price_range + dblL_price_min;
   }
   else
   {
      dblL_idx_base    = .4;
      dblL_idx_step    = -.05;     
      dlbL_Gdzie_1 = (dblL_idx_base + 0*dblL_idx_step) * dblL_price_range + dblL_price_min;
      dlbL_Gdzie_2 = (dblL_idx_base + 1*dblL_idx_step) * dblL_price_range + dblL_price_min;
      dlbL_Gdzie_3 = (dblL_idx_base + 2*dblL_idx_step) * dblL_price_range + dblL_price_min;
      dlbL_Gdzie_4 = (dblL_idx_base + 3*dblL_idx_step) * dblL_price_range + dblL_price_min;
      dlbL_Gdzie_5 = (dblL_idx_base + 4*dblL_idx_step) * dblL_price_range + dblL_price_min;
      dlbL_Gdzie_6 = (dblL_idx_base + 5*dblL_idx_step) * dblL_price_range + dblL_price_min;
      dlbL_Gdzie_7 = (dblL_idx_base + 7*dblL_idx_step) * dblL_price_range + dblL_price_min;
   }
   
   //print_elliott_letters("Arial Narrow",  10,clrOrange,     col_fale_RomanBracekt,  "RomanInBrackets", dlbL_Gdzie_1);
   //print_elliott_letters("Arial",         12,clrOrange,     col_fale_Roman,         "Roman",           dlbL_Gdzie_2);
   //print_elliott_letters("Arial Black",   12,clrPlum,       col_fale_Small,         "SmallCaps",       dlbL_Gdzie_3);
   //print_elliott_letters("Arial Black",   14,clrMagenta,    col_fale_Capital,       "Capitals",    dlbL_Gdzie_4);
   //print_elliott_letters("Arial Black",   16,clrAqua,       col_fale_Capital,       "Capitals+",   dlbL_Gdzie_5);
   //print_elliott_letters("Arial Black",   18,clrDeepSkyBlue,col_fale_CapitalBracket,"BigCaps",     dlbL_Gdzie_6);
   //print_elliott_letters("Century Gothic",14,clrSilver,     col_fale_ALT,           "Alt",         dlbL_Gdzie_7);
   
   int intL_WinIdx;// = find_RSI_Magic_Window();
   intL_WinIdx = 0;
   //if (intL_WinIdx>0)
   //{
   //   dlbL_Gdzie_1 = 5;
   //   dlbL_Gdzie_2 = 15;
   //   dlbL_Gdzie_3 = 25;
   //   dlbL_Gdzie_4 = 75;
   //   dlbL_Gdzie_5 = 95;
   //   //dlbL_Gdzie_6 = 60;
   //   //dlbL_Gdzie_7 = 70;
   //}

   print_elliott_letters("Arial",         10,clrGold,       col_fale_RomanBracekt,  "Lev1",  dlbL_Gdzie_1,intL_WinIdx);
   print_elliott_letters("Arial Black",   12,clrGold,       col_fale_Roman,         "Lev2",  dlbL_Gdzie_2,intL_WinIdx); //popravka 02.09.2018
   print_elliott_letters("Arial",         16,clrAqua,       col_fale_Small,         "Lev3",  dlbL_Gdzie_3,intL_WinIdx);
   print_elliott_letters("Arial Black",   16,clrDarkOrchid, col_fale_Capital,       "Lev4",  dlbL_Gdzie_4,intL_WinIdx);
   print_elliott_letters("Arial Black",   20,clrOrange,     col_fale_Capital,       "Lev5",  dlbL_Gdzie_5,intL_WinIdx);
   if (intL_WinIdx==0) print_elliott_letters("Arial Black",   22,clrDeepSkyBlue,col_fale_CapitalBracket,"Lev6",  dlbL_Gdzie_6,intL_WinIdx);
   if (intL_WinIdx==0) print_elliott_letters("Century Gothic",14,clrSilver,     col_fale_ALT,           "Alt",   dlbL_Gdzie_7,intL_WinIdx);
}
//+------------------------------------------------------------------+
void delete_Waves()
{
//20190105 kasuje aktywne elliotty
   bool blnL_f = true;
   int intL_p = 0, intL_pp = 0;
   while(blnL_f && !IsStopped()) 
   { 
      blnL_f = false;
      intL_pp++;
      //Alert("przelot ",intL_pp," objektów=",ObjectsTotal());
      for(int i=0;i<ObjectsTotal();i++)
      {
         string strL_TxtName = ObjectName(i);
         //
         if(StringSubstr(strL_TxtName,0,2) == "el")
         if(ObjectGetInteger(lngG_ID,strL_TxtName,OBJPROP_SELECTED,true))
         {
            ObjectDelete(strL_TxtName);
            blnL_f = true;
            intL_p++;            
         }
      }  
   }
   //Alert("Wykasowałem  = ", intL_p," Elliott Letters w ", intL_pp," przelotach");
}
//+------------------------------------------------------------------+
void print_elliott_letters(string head_Font, int head_FontSize, color head_Color,string& head_kolekcja[], string head_extention, double head_Y,const int head_Win = 0)
{
   //20180828
   int intL_BarsOnChart = WindowBarsPerChart();
   int intL_Bar_First   = WindowFirstVisibleBar() - intL_BarsOnChart * 0.9;   if(intL_Bar_First <0) intL_Bar_First = 0;
   int intL_Size        = ArraySize(head_kolekcja);
   int intL_Step        = MathRound(intL_BarsOnChart*.4/13);   //było 17 na początku
   
//   if(blnE_EllioTTonRSI)
//   {
//      
//      WindowFind(
//      Simon's Magic RSI
//      create_Text(lngG_ID,strL_Name,0,Time[intL_Bar_First+(intL_Size-i)*intL_Step],head_Y,strL_col_n,"Arial Black",  12,            clrRed,    0,ANCHOR_LEFT_UPPER,false,true,false);
//   
//   
//   }
   
   for(int i=0;i<intL_Size;i++)
   {
      string strL_col_n = head_kolekcja[i];
      string strL_Name_Base = "el "  + head_extention + " " + strL_col_n;
      string strL_Name = strL_Name_Base;
      int j=0;      
      if(ObjectFind(lngG_ID,strL_Name)>-1)
      do
      {
         j++;
         
         strL_Name = strL_Name_Base + " " + IntegerToString(j);
         if (j>144) break;
      }
      while(ObjectFind(lngG_ID,strL_Name)>-1 && !IsStopped());
      
      if       (strL_col_n == "RR")    create_Text(lngG_ID,strL_Name,head_Win,Time[intL_Bar_First+(intL_Size-i)*intL_Step],head_Y,strL_col_n,"Arial Black",  12,            clrRed,    0,ANCHOR_LEFT_UPPER,false,true,false);
      else if  (strL_col_n == "LL")    create_Text(lngG_ID,strL_Name,head_Win,Time[intL_Bar_First+(intL_Size-i)*intL_Step],head_Y,strL_col_n,"Arial Black",  12,            clrMagenta,0,ANCHOR_LEFT_UPPER,false,true,false);
      else if  (strL_col_n == "BS")    create_Text(lngG_ID,strL_Name,head_Win,Time[intL_Bar_First+(intL_Size-i)*intL_Step],head_Y,strL_col_n,"Arial Black",  12,            clrViolet, 0,ANCHOR_LEFT_UPPER,false,true,false);
      else if  (strL_col_n == "UP")    create_Text(lngG_ID,strL_Name,head_Win,Time[intL_Bar_First+(intL_Size-i)*intL_Step],head_Y,strL_col_n,"Arial Black",  12,            clrLime,   0,ANCHOR_LEFT_UPPER,false,true,false);
      else if  (strL_col_n == "DOWN")  create_Text(lngG_ID,strL_Name,head_Win,Time[intL_Bar_First+(intL_Size-i)*intL_Step],head_Y,strL_col_n,"Arial Black",  12,            clrRed,    0,ANCHOR_LEFT_UPPER,false,true,false);
      else                          create_Text(lngG_ID,strL_Name,head_Win,Time[intL_Bar_First+(intL_Size-i)*intL_Step],head_Y,strL_col_n,head_Font,      head_FontSize, head_Color,   0,ANCHOR_LEFT_UPPER,false,true,false);
   }
}
////+------------------------------------------------------------------+
//int find_RSI_Magic_Window()
//{
////20190309
//   if(blnE_EllioTTonRSI)
//   for(int i=0;i<=WindowsTotal();i++)
//   {
//      if( i == WindowFind("Simon's Magic RSI")) 
//      {
//         //Alert( i );
//         return i;
//      }
//      
//   }
//   return 0;
//}
////+------------------------------------------------------------------+
bool add_W13x5()
{
//20180303

   int intL_I0 = calc_I0();
   int intL_I1 = calc_I1();
   int intL_I2 = calc_I2();;
   
   double dblL_P0 = calc_P0();
   double dblL_P1 = calc_P1();
   double dblL_P2 = calc_P2();
   
   create_Fibo_Exp(ChartID(),strG_W15_Fibo_Nazwa,0,Time[intL_I0],dblL_P0,Time[intL_I1],dblL_P1, Time[intL_I2],dblL_P2,clrE_W15_Color);

   ObjectSetInteger  (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELS,12); 
   ObjectSetInteger  (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELCOLOR,clrE_W15_Color); 
   ObjectSetInteger  (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELSTYLE,stlE_W15_Style); 
   ObjectSetInteger  (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELWIDTH,1); 

   ObjectSetDouble   (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELVALUE,0,0.300);
   ObjectSetDouble   (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELVALUE,1,0.382);
   ObjectSetDouble   (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELVALUE,2,0.486);      
   ObjectSetDouble   (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELVALUE,3,0.618);
   ObjectSetDouble   (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELVALUE,4,0.786);
   ObjectSetDouble   (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELVALUE,5,1.000);
   ObjectSetDouble   (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELVALUE,6,1.272);
   ObjectSetDouble   (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELVALUE,7,1.618);
   ObjectSetDouble   (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELVALUE,8,2.058);
   ObjectSetDouble   (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELVALUE,9,2.618);
   ObjectSetDouble   (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELVALUE,10,3.330);
   ObjectSetDouble   (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELVALUE,11,4.236);

   ObjectSetString   (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELTEXT,0,"W1-3:5 30.0 (%$)"); 
   ObjectSetString   (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELTEXT,1,"W1-3:5 38.2 (%$)"); 
   ObjectSetString   (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELTEXT,2,"W1-3:5 48.6 (%$)"); 
   ObjectSetString   (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELTEXT,3,"W1-3:5 61.8 (%$)"); 
   ObjectSetString   (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELTEXT,4,"W1-3:5 78.6 (%$)"); 
   ObjectSetString   (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELTEXT,5,"W1-3:5 100.0 (%$)"); 
   ObjectSetString   (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELTEXT,6,"W1-3:5 127.2 (%$)"); 
   ObjectSetString   (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELTEXT,7,"W1-3:5 161.8 (%$)"); 
   ObjectSetString   (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELTEXT,8,"W1-3:5 205.8 (%$)"); 
   ObjectSetString   (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELTEXT,9,"W1-3:5 261.8 (%$)"); 
   ObjectSetString   (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELTEXT,10,"W1-3:5 333.0 (%$)"); 
   ObjectSetString   (ChartID(),strG_W15_Fibo_Nazwa,OBJPROP_LEVELTEXT,11,"W1-3:5 423.6 (%$)"); 
     
   return true;
}
////+------------------------------------------------------------------+
//void delete_All_Geo()
//{   
//   for(int i=0;i<=25;i++)  ObjectDelete(lngG_ID,col_Fibo[i]);
//}
//
//+------------------------------------------------------------------+
void delete_All_Geo_All()
{   
//20190524 kasuje totalnie wszystkie geometrie na wykresie
   
   bool blnL_f = true;
   int intL_p = 0, intL_pp = 0;
   while(blnL_f && !IsStopped()&& intL_p<100) 
   { 
      intL_pp++;
      blnL_f = false;
      for(int i=0;i<ObjectsTotal(ChartID(),0,OBJ_EXPANSION);i++)
      {
            string strL_Name = ObjectName(ChartID(),i,0,OBJ_EXPANSION);
            ObjectDelete(strL_Name);
            blnL_f = true;
            intL_p++;
      }
      
      for(int i=0;i<ObjectsTotal(ChartID(),0,OBJ_FIBO);i++)
      {
            string strL_Name = ObjectName(ChartID(),i,0,OBJ_FIBO);
            ObjectDelete(strL_Name);
            blnL_f = true;
            intL_p++;        
      }
   }
   //Alert("Wykasowałem  = ", intL_p," geom. w ", intL_pp," przelotach");
}

////+------------------------------------------------------------------+
//bool count_SameBars()
//{
//   //20180518
//   //20180609 dodaje veekendy
//
//   int intL_i;
//   int intL_DoW = TimeDayOfWeek(TimeGMT());
//   //if(intL_DoW == 6 || intL_DoW == 0)
//   if(!MarketInfo(Symbol(), MODE_TRADEALLOWED) || intL_DoW == 6 || intL_DoW == 0)
//   {
//      intL_i = 0;
//   }
//   else
//   {
//      intL_i = 1;
//   }
//   double dblL_dB1 = Close[intL_i] - Open[intL_i];
//   double dblL_Bn  = Close[intL_i] - Open[intL_i];
//   
//   int intL_base = intL_i+1;
//   int intL_n = intL_base;
//   while(dblL_dB1*dblL_Bn>0 && intL_n<100)
//   {
//      dblL_Bn = Close[intL_n] - Open[intL_n];
//      intL_n++;
//   }
//   if (dblL_dB1>0)      ObjectSetInteger(ChartID(),strG_Label_BarCount,OBJPROP_COLOR,clrLime); 
//   else if (dblL_dB1<0) ObjectSetInteger(ChartID(),strG_Label_BarCount,OBJPROP_COLOR,clrRed); 
//   else                 ObjectSetInteger(ChartID(),strG_Label_BarCount,OBJPROP_COLOR,clrSilver); 
//   string strL_BC = IntegerToString(intL_n-intL_base);
//   if (intL_i==0) strL_BC = strL_BC+"*";
//   
//   ObjectSetString(ChartID(),strG_Label_BarCount,OBJPROP_TEXT,strL_BC);
//
//   return true;
//}
////+------------------------------------------------------------------+
datetime calc_OpenPrice_Time()
{
   //20180824
   //20180831 // tutaj blokada zeby przynajmniej co minute spravdzalo nie czesciej
   //Alert("Obliczam Czas Otwarcia ", Period());
   for(int i=0;i<1440;i++)
   {
      if(TimeHour(iTime(NULL,PERIOD_M1,i)) == intE_Godz)
      if(TimeMinute(iTime(NULL,PERIOD_M1,i)) == intE_Min)
      {      
         datetime dttL_OTime = iTime(NULL,PERIOD_M1,i);
         //Alert(Symbol()," ",translate_TF_Name(Period())," Teraz Szukam Open Time");
         return iTime(NULL,PERIOD_M1,i);
      }
   }
   return 0;
}
////+------------------------------------------------------------------+
datetime calc_OpenPrice_Bar_M1()
{
   //20180824
   //20180831 // tutaj blokada zeby przynajmniej co minute spravdzalo nie czesciej
   for(int i=0;i<1440;i++)
   {
      if(TimeHour(iTime(NULL,PERIOD_M1,i)) == intE_Godz)
      if(TimeMinute(iTime(NULL,PERIOD_M1,i)) == intE_Min)
      {      
         datetime dttL_OTime = iTime(NULL,PERIOD_M1,i);
         return i;
      }
   }
   return 0;
}
//+------------------------------------------------------------------+
int calc_OpenPrice_I_TTF()
{
   //20180824  
   datetime dttL_OP_Time = calc_OpenPrice_Time();
   
   return iBarShift(NULL,0,dttL_OP_Time);
}
//+------------------------------------------------------------------+
double calc_OpenPrice_Val()
{
   //20180824
   datetime dttL_OP_Time = calc_OpenPrice_Time();   
   int      intL_OP_i   = iBarShift(NULL,PERIOD_M1,dttL_OP_Time);
   
   return   iOpen(NULL,PERIOD_M1,intL_OP_i);
}
//+------------------------------------------------------------------+
double calc_HighOfDay_Modified_Val()
{
   //20190525
   datetime    dttL_OP_Time = calc_OpenPrice_Time();        //oblicza do kiedy sprawdzać
   int         i = 0;                                       //zlicza przeloty
   datetime    dttL_BarTime = iTime(NULL,PERIOD_M1,i);      //czas na bazie przelotu
   double      dblL_HighOfDay_Mod = iHigh(NULL,PERIOD_M1,i);//max dzienny modyfikowany o czas otwarcia
   
   while(dttL_BarTime>=dttL_OP_Time && i<1441)              //minut w dobie jest 1440
   {
      i++; dttL_BarTime = iTime(NULL,PERIOD_M1,i);
      double dblL_H = iHigh(NULL,PERIOD_M1,i);
      if(dblL_H > dblL_HighOfDay_Mod) dblL_HighOfDay_Mod = dblL_H;
   }

   return dblL_HighOfDay_Mod;
}
//+------------------------------------------------------------------+
double calc_LowOfDay_Modified_Val()
{
   //20190525
   datetime    dttL_OP_Time = calc_OpenPrice_Time();        //oblicza do kiedy sprawdzać
   int         i = 0;                                       //zlicza przeloty
   datetime    dttL_BarTime = iTime(NULL,PERIOD_M1,i);      //czas na bazie przelotu
   double      dblL_LowOfDay_Mod = iLow(NULL,PERIOD_M1,i);  //max dzienny modyfikowany o czas otwarcia
   //int         j=0;
   while(dttL_BarTime>=dttL_OP_Time && i<1441)              //minut w dobie jest 1440
   {
      i++; dttL_BarTime = iTime(NULL,PERIOD_M1,i);
      double dblL_L = iLow(NULL,PERIOD_M1,i);
      if(dblL_L < dblL_LowOfDay_Mod)
      {
         dblL_LowOfDay_Mod = dblL_L;
         //j=i;
      }
   }
   //if(Period() == PERIOD_M1) Alert("j=",j," Val=",dblL_LowOfDay_Mod);

   return dblL_LowOfDay_Mod;
}
//+------------------------------------------------------------------+
double calc_OpenOfDay_Modified_Val()
{
   //20190530
   int         intL_OP_Bar_M1 = calc_OpenPrice_Bar_M1();        //oblicza do kiedy sprawdzać
   double      dblL_OpenOfDay_Mod = iOpen(NULL,PERIOD_M1,intL_OP_Bar_M1);

   return dblL_OpenOfDay_Mod;
}
////+------------------------------------------------------------------+
//bool count_PriceChange()
//{
//   //przechodzi z OnCalculate i tylko z jednego tego miejsca
//   
//   double dblL_d;
//   string strL_d;
//   int intL_i; //która cena czy ostatnia czy przedostatnia  
//   int intL_DoW = TimeDayOfWeek(TimeGMT());
//   
//   if(!MarketInfo(Symbol(), MODE_TRADEALLOWED) || intL_DoW == 6 || intL_DoW == 0)
//      intL_i = 0;
//   else
//      intL_i = 1;
// 
//   if       (Period() > PERIOD_H4)
//   {
//         dblL_d = Close[intL_i] - Open[intL_i];
//   }
//   else
//   {
//      double dblL_OP_Val; 
//      if(ObjectFind(lngG_ID,strG_OP_Line)>-1)
//      {
//         dblL_OP_Val = ObjectGetDouble(lngG_ID,strG_OP_Line,OBJPROP_PRICE1);
//      }
//      else
//      {
//         dblL_OP_Val = calc_OpenPrice_Val();
//      }         
//      dblL_d = Close[0] - dblL_OP_Val;
//   }
//
//   strL_d = DoubleToStr(dblL_d,Digits());
//
//   if(intL_i == 0) strL_d = strL_d+"*";
//   ObjectSetString(ChartID(),strG_Label_Change,OBJPROP_TEXT,strL_d);
//
//   return true;
//}
//+------------------------------------------------------------------+ 
//| Create Fibonacci Extension by the given coordinates              | 
//+------------------------------------------------------------------+ 
bool create_Fibo_Exp(const long            chart_ID=0,           // chart's ID 
                         const string          name="FiboExpansion", // channel name 
                         const int             sub_window=0,         // subwindow index  
                         datetime              time1=0,              // first point time 
                         double                price1=0,             // first point price 
                         datetime              time2=0,              // second point time 
                         double                price2=0,             // second point price 
                         datetime              time3=0,              // third point time 
                         double                price3=0,             // third point price 
                         const color           clr=clrRed,           // object color 
                         const ENUM_LINE_STYLE style=STYLE_SOLID,    // style of the lines 
                         const int             width=1,              // width of the lines 
                         const bool            back=false,           // in the background 
                         const bool            selection=true,       // highlight to move 
                         const bool            ray_right=true,      // object's continuation to the right 
                         const bool            hidden=false,          // hidden in the object list 
                         const long            z_order=0)            // priority for mouse click 
{ 
//--- set anchor points' coordinates if they are not set 
   //ChangeFiboExpansionEmptyPoints(time1,price1,time2,price2,time3,price3); 
//--- reset the error value 
   
   //odrzuca sytuacje, gdy obiekt już istnieje i nie ma sensu go na nowo tworzyć
   if(ObjectFind(chart_ID,name)>=0) return true;
   
   //ObjectDelete(chart_ID,name);   

   ResetLastError(); 
//--- Create Fibonacci Extension by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_EXPANSION,sub_window,time1,price1,time2,price2,time3,price3)) 
     { 
      Alert(__FUNCTION__, 
            ": failed to create \"Fibonacci Extension\"! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set the object's color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- set the line style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- set width of the lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of highlighting the channel for moving 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- enable (true) or disable (false) the mode of continuation of the object's display to the right 
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right); 
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- successful execution 
   return(true); 
} 
//+------------------------------------------------------------------+
//+                                                                  +
//+------------------------------------------------------------------+
bool create_Fibo_Ret(const long            chart_ID=0,        // chart's ID 
                      const string          name="FiboLevels", // object name 
                      const int             sub_window=0,      // subwindow index  
                      datetime              time1=0,           // first point time 
                      double                price1=0,          // first point price 
                      datetime              time2=0,           // second point time 
                      double                price2=0,          // second point price 
                      const color           clr=clrRed,        // object color 
                      const ENUM_LINE_STYLE style=STYLE_DOT,   // object line style 
                      const int             width=1,           // object line width 
                      const bool            back=false,        // in the background 
                      const bool            selection=true,    // highlight to move 
                      const bool            ray_right=true,   // object's continuation to the right 
                      const bool            hidden=false,       // hidden in the object list 
                      const long            z_order=0)         // priority for mouse click 
{ 
////--- set anchor points' coordinates if they are not set 
//   ChangeFiboLevelsEmptyPoints(time1,price1,time2,price2); 
//--- reset the error value 
   ResetLastError();
   
   //odrzuca sytuacje, gdy obiekt już istnieje i nie ma sensu go na nowo tworzyć
   if(ObjectFind(chart_ID,name)>=0) return true;
   
   //kasowanie jesli juz zostal stworzony wczesniej
   //ObjectDelete(chart_ID,name); 

   //--- Create Fibonacci Retracement by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_FIBO,sub_window,time1,price1,time2,price2)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create \"Fibonacci Retracement\"! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- set line style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- set line width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of highlighting the channel for moving 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- enable (true) or disable (false) the mode of continuation of the object's display to the right 
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right); 
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- successful execution 
   return(true); 
}
//+------------------------------------------------------------------+
void check_FiboObjects()
{
   for(int i=0;i<11;i++)
      check_IfObjectCreated(col_Fibo[i],col_Buttons[i]);
}
//+------------------------------------------------------------------+
bool check_IfObjectCreated(string head_NazwaObjektu, string head_NazwaGuzika)
{
   if(ObjectFind(ChartID(),head_NazwaObjektu)>-1)
   {
      if(ObjectGetInteger(ChartID(),head_NazwaObjektu,OBJPROP_SELECTED))
      {
         ObjectSetInteger(ChartID(),head_NazwaGuzika,OBJPROP_BORDER_COLOR,clrRed);
         return true;
      }
      else
      {
         ObjectSetInteger(ChartID(),head_NazwaGuzika,OBJPROP_BORDER_COLOR,clrAqua);
         return true;
      }
   }
   else
   {
      ObjectSetInteger(ChartID(),head_NazwaGuzika,OBJPROP_BORDER_COLOR,clrNONE);
   }
   
   return false;
}
////+------------------------------------------------------------------+
bool check_BarsAndCandles()
{
  ENUM_CHART_MODE enmL_ChartMode = ChartGetInteger(ChartID(),CHART_MODE);
  
  if(enmL_ChartMode ==  CHART_BARS)
  {
      ObjectSetInteger(ChartID(),strG_Chart_Bars,     OBJPROP_STATE,true);
      ObjectSetInteger(ChartID(),strG_Chart_Candles,  OBJPROP_STATE,false);
      ObjectSetInteger(ChartID(),strG_Chart_Line,     OBJPROP_STATE,false);
  }
  else if(enmL_ChartMode == CHART_CANDLES)
  {
      ObjectSetInteger(ChartID(),strG_Chart_Bars,     OBJPROP_STATE,false);
      ObjectSetInteger(ChartID(),strG_Chart_Candles,  OBJPROP_STATE,true);
      ObjectSetInteger(ChartID(),strG_Chart_Line,     OBJPROP_STATE,false);
  }
  else if(enmL_ChartMode == CHART_LINE)
  {
      ObjectSetInteger(ChartID(),strG_Chart_Bars,     OBJPROP_STATE,false);
      ObjectSetInteger(ChartID(),strG_Chart_Candles,  OBJPROP_STATE,false);
      ObjectSetInteger(ChartID(),strG_Chart_Line,     OBJPROP_STATE,true);
  }
  else
  {
      ObjectSetInteger(ChartID(),strG_Chart_Bars,     OBJPROP_STATE,false);
      ObjectSetInteger(ChartID(),strG_Chart_Candles,  OBJPROP_STATE,false);
      ObjectSetInteger(ChartID(),strG_Chart_Line,     OBJPROP_STATE,false);
  }
  
   //kontrola guzika od separatorów okresów
   bool blnL_SepLine = ChartGetInteger(ChartID(),CHART_SHOW_PERIOD_SEP,0);
   if(blnL_SepLine) ObjectSetInteger(ChartID(),strG_Chart_SepLines,  OBJPROP_STATE,true);
   else             ObjectSetInteger(ChartID(),strG_Chart_SepLines,  OBJPROP_STATE,false); 

   return true;
}
//+------------------------------------------------------------------+
string name_OP_Line()
{
   string strL_Godz, strL_Min;
   if(intE_Godz<10)  strL_Godz   = "0"+IntegerToString(intE_Godz);  else strL_Godz  = IntegerToString(intE_Godz);
   if(intE_Min<10)   strL_Min    = "0"+IntegerToString(intE_Min);   else strL_Min   = IntegerToString(intE_Min);
   return "Linia Ceny Otwarcia" + " " + strL_Godz + ":" + strL_Min;
}
//+------------------------------------------------------------------+
string name_Mx_Line()
{
   string strL_Godz, strL_Min;
   if(intE_Godz<10)  strL_Godz   = "0"+IntegerToString(intE_Godz);  else strL_Godz  = IntegerToString(intE_Godz);
   if(intE_Min<10)   strL_Min    = "0"+IntegerToString(intE_Min);   else strL_Min   = IntegerToString(intE_Min);
   return Symbol()+"." + translate_TF(enmG_TF) + " Linia Ceny Daily Max";
}
//+------------------------------------------------------------------+
string name_Mn_Line()
{
   string strL_Godz, strL_Min;
   if(intE_Godz<10)  strL_Godz   = "0"+IntegerToString(intE_Godz);  else strL_Godz  = IntegerToString(intE_Godz);
   if(intE_Min<10)   strL_Min    = "0"+IntegerToString(intE_Min);   else strL_Min   = IntegerToString(intE_Min);
   return Symbol()+"." + translate_TF(enmG_TF) + " Linia Ceny Daily Min";
}

//+------------------------------------------------------------------+
bool draw_OP_Line()
{   
   //20190601 poprawiłem kod do linii otwarcia. wydłużyłem linię Base Line (HLC/3) na cały dzień
   //przerysovuje LINIE OTWARCIA
   //20190525     randge dzienny rysuje tylko z godzin handlu bez nocy poprzedzającej
   //20181204     dodałem linie max min
   //20180901  
   //20180822     po godzinie a nie po słupku szuka i to jest ok dla us30 gdzie jset przesuniecie o 5 min 
   //202180824:   przechodzi z OnCalculate gdy nowy bar
   //             przechodzi z OnChartEvent gdy guzik wciśnięty ze ma rysować
   
   //gdy guzik wyłączony kasuje linie
   bool blnL_OPL_State =  ObjectGetInteger(lngG_ID,strG_OPL_Button_Nazwa,OBJPROP_STATE);
   if(!blnL_OPL_State)
   {
      delete_OP_Line();
      return true;
   }

   //Alert("rysuję linię OP LINE ", Period());

   //gdy za duża skala nie działa bo i po co
   if(Period()>PERIOD_H4) return false;
   //-------------------------
   
   //łapie pierwszy słupek dnia po otwarciu sesji
   double   dblL_OP_Val       = calc_OpenPrice_Val();                                                          //oblicza bieżącą cenę otwarcia   
   int      intL_OP_i         = calc_OpenPrice_I_TTF();                                                        //bar bieżącej ceny otwarcia
   // czasowe zmienne
   datetime dttL_RangeLine    = Time[0] + Period()*60*intE_OP_Line_Shift;//3000;                                               //pozycja do linii przesunięta o 3000 sekund (50 min)
   datetime dttL_TextLine     = dttL_RangeLine + Period()*60*(intE_OP_Line_Shift-(intE_OP_Line_Shift*.8));//300;                                            //pozycja do opisów linii
   datetime dttL_GlutTime     = Time[0] + Period()*60*(intE_OP_Line_Shift-(intE_OP_Line_Shift*.3));//1800;                                                //pozycja do początku glut price
   datetime dttL_BaseTime     = calc_OpenPrice_Time();//Time[0] + Period()*60*(intE_OP_Line_Shift-(intE_OP_Line_Shift*.7));//1800;                                                //pozycja do początku base price
   datetime dttL_HA_BegTime   = Time[0] + Period()*60*intE_OP_Line_Shift;
   datetime dttL_HA_EndTime   = Time[0] + Period()*60*(intE_OP_Line_Shift+(intE_OP_Line_Shift*.1));
   // wartości
   double   dblL_Daily_H      = calc_HighOfDay_Modified_Val(); //iHigh(NULL,PERIOD_D1,0);                               //akt dzienny haj
   double   dblL_Daily_L      = calc_LowOfDay_Modified_Val();  //OfDay_Modified_ValiLow (NULL,PERIOD_D1,0);             //akt dzienny low   
   double   dblL_Daily_O      = calc_OpenOfDay_Modified_Val();
   double   dblL_RangeVal     = dblL_Daily_H - dblL_Daily_L;                                                            //obliczony daily range
   //20190601 oblicza netto ruch za dnia
   double  dblL_Daily_Net_Get       = iClose(NULL,PERIOD_D1,0) - dblL_Daily_O;
   //cont.
   string   strL_RangeVal     = "R:"+DoubleToStr(dblL_RangeVal,Digits()) + " p. G:"+DoubleToStr(dblL_Daily_Net_Get,Digits())+" p.";  //w postaci stringa
   double   dblL_BasePriceVal = (dblL_Daily_H + dblL_Daily_L + dblL_Daily_O)/3;                                                     //taka koślawa średnia dla dnia
   string   strL_BasePriceVal = "OHL/3="+DoubleToStr(dblL_BasePriceVal,Digits());                                                   //w postaci stringa ta średnia
   double   dblL_GlutPriceVal = (dblL_Daily_H + dblL_Daily_L + iClose(NULL,PERIOD_D1,0))/3;                                         //taka koślawa średnia dla dnia
   string   strL_GlutPriceVal = "HLC/3="+DoubleToStr(dblL_GlutPriceVal,Digits());                                                   //w postaci stringa ta średnia
   double   dblL_HA_Val       = (dblL_Daily_H + dblL_Daily_L + dblL_Daily_O + iClose(NULL,PERIOD_D1,0))/4;                          //HA Close Price
   
   

   //--- rysuje linię rendżową
   if(ObjectFind(lngG_ID,strG_Range_Line)>-1)
   {
      if (dttL_RangeLine != ObjectGetInteger  (lngG_ID,strG_Range_Line,OBJPROP_TIME1) ) ObjectSetInteger  (lngG_ID,strG_Range_Line,OBJPROP_TIME1, dttL_RangeLine);
      if (dblL_Daily_H   != ObjectGetDouble   (lngG_ID,strG_Range_Line,OBJPROP_PRICE1)) ObjectSetDouble   (lngG_ID,strG_Range_Line,OBJPROP_PRICE1,dblL_Daily_H);
      if (dttL_RangeLine != ObjectGetInteger  (lngG_ID,strG_Range_Line,OBJPROP_TIME2) ) ObjectSetInteger  (lngG_ID,strG_Range_Line,OBJPROP_TIME2, dttL_RangeLine);
      if (dblL_Daily_L   != ObjectGetDouble   (lngG_ID,strG_Range_Line,OBJPROP_PRICE2)) ObjectSetDouble   (lngG_ID,strG_Range_Line,OBJPROP_PRICE2,dblL_Daily_L);
   }
   else
      bool blnL_create = create_T_Line(lngG_ID,  strG_Range_Line,0,dttL_RangeLine,dblL_Daily_H,dttL_RangeLine,dblL_Daily_L,clrRoyalBlue,STYLE_SOLID,2,false,false);

   //--- wyświetla i aktualizuje dzienną zmienność
   if(ObjectFind(lngG_ID,strG_Daily_Range)>-1)
   {
      if (dttL_RangeLine != ObjectGetInteger (lngG_ID,strG_Daily_Range,OBJPROP_TIME)) ObjectSetInteger (lngG_ID,strG_Daily_Range,OBJPROP_TIME,dttL_RangeLine);
      if (dblL_Daily_H   != ObjectGetDouble  (lngG_ID,strG_Daily_Range,OBJPROP_PRICE))ObjectSetDouble  (lngG_ID,strG_Daily_Range,OBJPROP_PRICE,dblL_Daily_H);
      if (strL_RangeVal  != ObjectGetString  (lngG_ID,strG_Daily_Range,OBJPROP_TEXT)) ObjectSetString  (lngG_ID,strG_Daily_Range,OBJPROP_TEXT, strL_RangeVal);
   }
   else
      create_Text(lngG_ID,strG_Daily_Range,0,dttL_RangeLine,dblL_Daily_H,strL_RangeVal,"Arial",8,clrWhite,0,ANCHOR_LEFT_LOWER);
      
   //--- rysuje linię HA Close Price
   if(ObjectFind(lngG_ID,strG_HA_Close)>-1)
   {
      if (dttL_HA_BegTime  != ObjectGetInteger  (lngG_ID,strG_HA_Close,OBJPROP_TIME1) )   ObjectSetInteger   (lngG_ID,strG_HA_Close,OBJPROP_TIME1, dttL_HA_BegTime);
      if (dblL_HA_Val      != ObjectGetDouble   (lngG_ID,strG_HA_Close,OBJPROP_PRICE1))   ObjectSetDouble    (lngG_ID,strG_HA_Close,OBJPROP_PRICE1,dblL_HA_Val);
      if (dttL_HA_EndTime  != ObjectGetInteger  (lngG_ID,strG_HA_Close,OBJPROP_TIME2) )   ObjectSetInteger   (lngG_ID,strG_HA_Close,OBJPROP_TIME2, dttL_HA_EndTime);
      if (dblL_HA_Val      != ObjectGetDouble   (lngG_ID,strG_HA_Close,OBJPROP_PRICE2))   ObjectSetDouble    (lngG_ID,strG_HA_Close,OBJPROP_PRICE2,dblL_HA_Val);
   }
   else      
      create_T_Line(lngG_ID,  strG_HA_Close,0,dttL_HA_BegTime,dblL_HA_Val,dttL_HA_EndTime,dblL_HA_Val,clrGold,STYLE_SOLID,2,false,false);

   //--- rysuje linię BASE PRICE
   if(ObjectFind(lngG_ID,strG_GlutPrice)>-1)
   {
      if (dttL_BaseTime       != ObjectGetInteger  (lngG_ID,strG_BasePrice,OBJPROP_TIME1) )   ObjectSetInteger   (lngG_ID,strG_BasePrice,OBJPROP_TIME1, dttL_BaseTime);
      if (dblL_BasePriceVal   != ObjectGetDouble   (lngG_ID,strG_BasePrice,OBJPROP_PRICE1))   ObjectSetDouble    (lngG_ID,strG_BasePrice,OBJPROP_PRICE1,dblL_BasePriceVal);
      if (dttL_RangeLine      != ObjectGetInteger  (lngG_ID,strG_BasePrice,OBJPROP_TIME2) )   ObjectSetInteger   (lngG_ID,strG_BasePrice,OBJPROP_TIME2, dttL_RangeLine);
      if (dblL_BasePriceVal   != ObjectGetDouble   (lngG_ID,strG_BasePrice,OBJPROP_PRICE2))   ObjectSetDouble    (lngG_ID,strG_BasePrice,OBJPROP_PRICE2,dblL_BasePriceVal);
   }
   else      
      create_T_Line(lngG_ID,  strG_BasePrice,0,dttL_BaseTime,dblL_BasePriceVal,dttL_RangeLine,dblL_BasePriceVal,clrRoyalBlue,STYLE_DOT,2,false,false); 
   
   //wyświetla i aktualizuje BASE PRICE
   if(ObjectFind(lngG_ID,strG_BasePriceTxt)>-1)
   {
      if (dttL_TextLine       != ObjectGetInteger (lngG_ID,strG_BasePriceTxt,OBJPROP_TIME))  ObjectSetInteger (lngG_ID,strG_BasePriceTxt,OBJPROP_TIME, dttL_TextLine);
      if (dblL_BasePriceVal   != ObjectGetDouble  (lngG_ID,strG_BasePriceTxt,OBJPROP_PRICE)) ObjectSetDouble  (lngG_ID,strG_BasePriceTxt,OBJPROP_PRICE,dblL_BasePriceVal);
      if (strL_BasePriceVal   != ObjectGetString  (lngG_ID,strG_BasePriceTxt,OBJPROP_TEXT))  ObjectSetString  (lngG_ID,strG_BasePriceTxt,OBJPROP_TEXT, strL_BasePriceVal);
   }
   else
      create_Text(lngG_ID,strG_BasePriceTxt, 0,dttL_TextLine,dblL_BasePriceVal,strL_BasePriceVal,  "Arial",8,clrRoyalBlue,0,ANCHOR_LEFT_LOWER);
   
   //--- rysuje linię GLUT PRICE
   if(ObjectFind(lngG_ID,strG_GlutPrice)>-1)
   {
      if (dttL_GlutTime       != ObjectGetInteger  (lngG_ID,strG_GlutPrice,OBJPROP_TIME1) )  ObjectSetInteger  (lngG_ID,strG_GlutPrice,OBJPROP_TIME1, dttL_GlutTime);
      if (dblL_GlutPriceVal   != ObjectGetDouble   (lngG_ID,strG_GlutPrice,OBJPROP_PRICE1))  ObjectSetDouble   (lngG_ID,strG_GlutPrice,OBJPROP_PRICE1,dblL_GlutPriceVal);
      if (dttL_RangeLine      != ObjectGetInteger  (lngG_ID,strG_GlutPrice,OBJPROP_TIME2) )  ObjectSetInteger  (lngG_ID,strG_GlutPrice,OBJPROP_TIME2, dttL_RangeLine);
      if (dblL_GlutPriceVal   != ObjectGetDouble   (lngG_ID,strG_GlutPrice,OBJPROP_PRICE2))  ObjectSetDouble   (lngG_ID,strG_GlutPrice,OBJPROP_PRICE2,dblL_GlutPriceVal);
   }
   else     
      create_T_Line(lngG_ID,  strG_GlutPrice,0,dttL_GlutTime,dblL_GlutPriceVal,dttL_RangeLine,dblL_GlutPriceVal,clrSkyBlue,STYLE_SOLID,2,false,false);
   //--- wyświetla i aktualizuje glut price
   if(ObjectFind(lngG_ID,strG_GlutPriceTxt)>-1)
   {
      if (dttL_TextLine       != ObjectGetInteger (lngG_ID,strG_GlutPriceTxt,OBJPROP_TIME))  ObjectSetInteger (lngG_ID,strG_GlutPriceTxt,OBJPROP_TIME, dttL_TextLine);
      if (dblL_GlutPriceVal   != ObjectGetDouble  (lngG_ID,strG_GlutPriceTxt,OBJPROP_PRICE)) ObjectSetDouble  (lngG_ID,strG_GlutPriceTxt,OBJPROP_PRICE,dblL_GlutPriceVal);
      if (strL_GlutPriceVal   != ObjectGetString  (lngG_ID,strG_GlutPriceTxt,OBJPROP_TEXT))  ObjectSetString  (lngG_ID,strG_GlutPriceTxt,OBJPROP_TEXT, strL_GlutPriceVal);
   }
   else
      create_Text(lngG_ID,strG_GlutPriceTxt, 0,dttL_TextLine,dblL_GlutPriceVal,strL_GlutPriceVal,  "Arial",8,clrSkyBlue,0,ANCHOR_LEFT_LOWER);
   
   if(dblL_GlutPriceVal>dblL_BasePriceVal)
   {
      ObjectSetInteger (lngG_ID,strG_BasePriceTxt,OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      ObjectSetInteger (lngG_ID,strG_GlutPriceTxt,OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
   }
   else
   {
      ObjectSetInteger (lngG_ID,strG_BasePriceTxt,OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
      ObjectSetInteger (lngG_ID,strG_GlutPriceTxt,OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
   }

   //---popravia położenie openpriceline
   if(ObjectFind(lngG_ID,strG_OP_Line)>-1)
   {
      //if (Minute()== intG_Minute || intG_Minute==1) return false;
      if (Time[intL_OP_i]  != ObjectGetInteger  (lngG_ID,strG_OP_Line,OBJPROP_TIME1) )   ObjectSetInteger  (lngG_ID,strG_OP_Line,OBJPROP_TIME1,Time[intL_OP_i]);
      if (dblL_OP_Val      != ObjectGetDouble   (lngG_ID,strG_OP_Line,OBJPROP_PRICE1))   ObjectSetDouble   (lngG_ID,strG_OP_Line,OBJPROP_PRICE1,dblL_OP_Val);
      if (dttL_RangeLine   != ObjectGetInteger  (lngG_ID,strG_OP_Line,OBJPROP_TIME2) )   ObjectSetInteger  (lngG_ID,strG_OP_Line,OBJPROP_TIME2,dttL_RangeLine);
      if (dblL_OP_Val      != ObjectGetDouble   (lngG_ID,strG_OP_Line,OBJPROP_PRICE2))   ObjectSetDouble   (lngG_ID,strG_OP_Line,OBJPROP_PRICE2,dblL_OP_Val);
      //Alert("Poprawiam Linię OPL ", translate_TF_Name(Period()));
   }
   else //rysuje novą linię
      create_T_Line(ChartID(),strG_OP_Line,0,Time[intL_OP_i],dblL_OP_Val,dttL_RangeLine,dblL_OP_Val,clrE_OP_Color,STYLE_DASH,1,false,false);

   //---
   dblG_Daily_Mx = dblL_Daily_H;
   dblG_Daily_Mn = dblL_Daily_L;
   
   return true;
}
//+------------------------------------------------------------------+
bool manage_OP_Line()
{
   if(ObjectFind(ChartID(),strG_OP_Line)<0) return false;

   double dblL_price = ObjectGetDouble(ChartID(),strG_OP_Line,OBJPROP_PRICE1);

   if       (Bid > dblL_price)
   {
      ObjectSetInteger(ChartID(),strG_OP_Line,OBJPROP_COLOR,clrLime);
      ObjectSetInteger(ChartID(),strG_OPL_Button_Nazwa,OBJPROP_COLOR,clrBlack); 
      ObjectSetInteger(ChartID(),strG_OPL_Button_Nazwa,OBJPROP_BGCOLOR,clrLime);
      ObjectSetString(ChartID(),strG_OPL_Button_Nazwa,OBJPROP_FONT,"Arial Black");
      ObjectSetInteger(ChartID(),strG_OPL_Button_Nazwa,OBJPROP_BORDER_COLOR,clrBlack); 
   }
   else if  (Bid < dblL_price)
   {
      ObjectSetInteger(ChartID(),strG_OP_Line,OBJPROP_COLOR,clrRed);
      ObjectSetInteger(ChartID(),strG_OPL_Button_Nazwa,OBJPROP_COLOR,clrBlack); 
      ObjectSetInteger(ChartID(),strG_OPL_Button_Nazwa,OBJPROP_BGCOLOR,clrRed); 
      ObjectSetString(ChartID(),strG_OPL_Button_Nazwa,OBJPROP_FONT,"Arial Black"); 
      ObjectSetInteger(ChartID(),strG_OPL_Button_Nazwa,OBJPROP_BORDER_COLOR,clrBlack); 
   }
   else
   {
      ObjectSetInteger(ChartID(),strG_OP_Line,OBJPROP_COLOR,clrE_OP_Color);
      ObjectSetInteger(ChartID(),strG_OPL_Button_Nazwa,OBJPROP_BGCOLOR,C'236,233,216');
      ObjectSetString(ChartID(),strG_OPL_Button_Nazwa,OBJPROP_FONT,"Arial"); 
   }
   return true;
}
//+------------------------------------------------------------------+
bool delete_OP_Line()
{

   ObjectDelete(ChartID(),strG_OP_Line);
   ObjectDelete(ChartID(),strG_Daily_Range);
   ObjectDelete(ChartID(),strG_Range_Line);
   ObjectDelete(ChartID(),strG_BasePrice);
   ObjectDelete(ChartID(),strG_BasePriceTxt);
   ObjectDelete(ChartID(),strG_GlutPrice);
   ObjectDelete(ChartID(),strG_GlutPriceTxt);
   ObjectDelete(ChartID(),strG_HA_Close);
   
   return true;

}
//+------------------------------------------------------------------+ 
//| Create a trend line by the given coordinates                     | 
//+------------------------------------------------------------------+ 
bool create_T_Line(const long          chart_ID=0,        // chart's ID 
                 const string          name="TrendLine",  // line name 
                 const int             sub_window=0,      // subwindow index 
                 datetime              time1=0,           // first point time 
                 double                price1=0,          // first point price 
                 datetime              time2=0,           // second point time 
                 double                price2=0,          // second point price 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=true,         // in the background 
                 const bool            selection=true,    // highlight to move 
                 const bool            ray_right=false,   // line's continuation to the right 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0)         // priority for mouse click 
  { 
//--- reset the error value 
   ResetLastError(); 
//--- create a trend line by the given coordinates 
   if(!ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,time1,price1,time2,price2)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create a trend line! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set line color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- set line display style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- set line width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of moving the line by mouse 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- enable (true) or disable (false) the mode of continuation of the line's display to the right 
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right); 
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- successful execution 

  // Alert("ive just created ",name," trend line. ",Symbol(),".",Period());
   return(true); 
  }
//+------------------------------------------------------------------+ 
//| Move trend line anchor point                                     | 
//+------------------------------------------------------------------+ 
bool change_TrendPoint(const long  chart_ID=0,       // chart's ID 
                      const string name="TrendLine", // line name 
                      const int    point_index=0,    // anchor point index 
                      datetime     time=0,           // anchor point time coordinate 
                      double       price=0)          // anchor point price coordinate 
{ 
//--- if point position is not set, move it to the current bar having Bid price 
   if(!time) 
      time=TimeCurrent(); 
   if(!price) 
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID); 
//--- reset the error value 
   ResetLastError(); 
//--- move trend line's anchor point 
   if(!ObjectMove(chart_ID,name,point_index,time,price)) 
     { 
      Print(__FUNCTION__, 
            ": failed to move the anchor point! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- successful execution 
   return(true); 
} 
//+------------------------------------------------------------------+
//+ Support/Resistance lines   
//+------------------------------------------------------------------+
bool draw_SR_Line(const ENUMs_SR_Line head_SR = line_SR_C)
{
   string strL_Line_Name;
   color  clrL_Color = clrSilver;
   
   switch(head_SR)
   {
      case  line_SR_S:  strL_Line_Name = strG_SR_S_Line; clrL_Color=clrLime; break;
      case  line_SR_R:  strL_Line_Name = strG_SR_R_Line; clrL_Color=clrRed;  break;
   }

   for(int i=0;i<99;i++)
   {
      string strL_X_LineName = StringConcatenate(strL_Line_Name,IntegerToString(i));
      if(ObjectFind(ChartID(),strL_X_LineName)<0)
      if(create_T_Line(lngG_ID,strL_X_LineName,0,Time[29],Open[0],Time[0],Open[0],clrL_Color,STYLE_SOLID,intE_SR_Width))
         return true;
   }
   
   return false;
}
//+------------------------------------------------------------------+
bool manage_SR_Lines()
{
   //20180808
   int intL_ObjTotal;
   intL_ObjTotal=ObjectsTotal(); 
   string strL_name; 
   for(int i=0;i<intL_ObjTotal;i++) 
   { 
      strL_name = ObjectName(i);
      if(StringSubstr(strL_name,0,3) == "Res")
      {
         double dblL_price = ObjectGetDouble(ChartID(),strL_name,OBJPROP_PRICE1);
         //Alert("Cena Linii ",strL_name,"=",dblL_price);
         if(Bid>dblL_price)
         {
            if(ObjectGetInteger(lngG_ID,strL_name,OBJPROP_COLOR)!= clrAqua) ObjectSetInteger(ChartID(),strL_name,OBJPROP_COLOR,clrAqua);
         }
         else
         {
            if(ObjectGetInteger(lngG_ID,strL_name,OBJPROP_COLOR)!= clrRed) ObjectSetInteger(ChartID(),strL_name,OBJPROP_COLOR,clrRed);
         }
      }
      else if (StringSubstr(strL_name,0,3) == "Sup")
      {
         double dblL_price = ObjectGetDouble(ChartID(),strL_name,OBJPROP_PRICE1);
         if(Bid<dblL_price)
         {
            if(ObjectGetInteger(lngG_ID,strL_name,OBJPROP_COLOR)!= clrAqua) ObjectSetInteger(ChartID(),strL_name,OBJPROP_COLOR,clrAqua);
         }
         else
         {
            if(ObjectGetInteger(lngG_ID,strL_name,OBJPROP_COLOR)!= clrLime) ObjectSetInteger(ChartID(),strL_name,OBJPROP_COLOR,clrLime);
         }
      }
   }        
   return true;
}
//+------------------------------------------------------------------+
void delete_SR_Line()
{
   //20190526 kasuje linie SR lines - zmiana kodu na bardziej elastyczny z tego co poniżej
   
   bool blnL_f = true;
   int intL_p = 0, intL_pp = 0;
   while(blnL_f && !IsStopped()&& intL_p<100) 
   { 
      intL_pp++;
      blnL_f = false;
      for(int i=0;i<ObjectsTotal(ChartID(),0,OBJ_TREND);i++)
      {
            string strL_Name = ObjectName(ChartID(),i,0,OBJ_TREND);
            if(StringSubstr(strL_Name,0,3) == "Sup" || StringSubstr(strL_Name,0,3) == "Res")
            {
               ObjectDelete(strL_Name);
               blnL_f = true;
               intL_p++;
            }
      }
   }
   //Alert("Wykasowałem  = ", intL_p," linii SR z prefixem <Sup> lub <Res> w ", intL_pp," przelotach");
   
   //return true;
   //for(int i=0;i<100;i++)
   //{
   //   string strL_S_LineName = StringConcatenate(strG_SR_S_Line,IntegerToString(i));
   //   if(ObjectFind(ChartID(),strL_S_LineName)== 0)
   //      ObjectDelete(lngG_ID,strL_S_LineName);
   //   else if(i>12) break;
   //}
   //for(int i=0;i<100;i++)
   //{
   //   string strL_R_LineName = StringConcatenate(strG_SR_R_Line,IntegerToString(i));
   //   if(ObjectFind(ChartID(),strL_R_LineName)== 0)
   //      ObjectDelete(lngG_ID,strL_R_LineName);
   //   else if(i>12) break;
   //}
   //return true;
}
//+------------------------------------------------------------------+
bool adjust_SR_Line()
{
   datetime dttL_End = Time[0] + Period()*60;

   for(int i=0;i<99;i++)
   {
      string strL_S_LineName = StringConcatenate(strG_SR_S_Line,IntegerToString(i));
      if(ObjectFind(ChartID(),strL_S_LineName)== 0)
      {
         double dblL_Price = ObjectGetDouble(lngG_ID,strL_S_LineName,OBJPROP_PRICE,0);
         change_TrendPoint(lngG_ID,strL_S_LineName,1,dttL_End,dblL_Price);
         ObjectSetInteger(lngG_ID,strL_S_LineName,OBJPROP_SELECTED,false); 
      }
      else if(i>12) break;
   }
   for(int i=0;i<99;i++)
   {
      string strL_R_LineName = StringConcatenate(strG_SR_R_Line,IntegerToString(i));
      if(ObjectFind(ChartID(),strL_R_LineName)== 0)
      {
         double dblL_Price = ObjectGetDouble(lngG_ID,strL_R_LineName,OBJPROP_PRICE,0);
         change_TrendPoint(lngG_ID,strL_R_LineName,1,dttL_End,dblL_Price);
         ObjectSetInteger(lngG_ID,strL_R_LineName,OBJPROP_SELECTED,false); 
      }
      else if(i>12) break;
   }
   return true;
}
//+------------------------------------------------------------------+
//+ trend lines   
//+------------------------------------------------------------------+
bool draw_T_Line_Up(const ENUM_LINE_STYLE head_style =  STYLE_DOT)
{
   string strL_Line_Name = "TL ";
   
   int intL_FBoC = MathRound(WindowFirstVisibleBar()*1.00); 
   int intL_P0   = iLowest(NULL,0,MODE_LOW,intL_FBoC,0);
   int intL_P1   = iLowest(NULL,0,MODE_LOW,intL_P0-5,0);

   for(int i=0;i<99;i++)
   {
      string strL_X_LineName = StringConcatenate(strL_Line_Name,IntegerToString(i));
      if(ObjectFind(ChartID(),strL_X_LineName)<0)
      if(create_T_Line(lngG_ID,strL_X_LineName,0,Time[intL_P0],Low[intL_P0],Time[intL_P1],Low[intL_P1],clrGold,head_style))
      {
         ObjectSetInteger(lngG_ID,strL_X_LineName,OBJPROP_RAY_RIGHT,true);
         ObjectSetInteger(lngG_ID,strL_X_LineName,OBJPROP_SELECTABLE,true); 
         ObjectSetInteger(lngG_ID,strL_X_LineName,OBJPROP_SELECTED,true); 
         ObjectSetInteger(lngG_ID,strL_X_LineName,OBJPROP_HIDDEN,false);          
         return true;
      }
   }
   return false;
}
//+------------------------------------------------------------------+
bool draw_T_Line_Dn(const ENUM_LINE_STYLE head_style =  STYLE_DOT)
{   
   string strL_Line_Name = "TL ";
   
   int intL_FBoC = MathRound(WindowFirstVisibleBar()*1.00); 
   int intL_P0   = iHighest(NULL,0,MODE_HIGH,intL_FBoC,0);
   int intL_P1   = iHighest(NULL,0,MODE_HIGH,intL_P0-5,0);

   for(int i=0;i<99;i++)
   {
      string strL_X_LineName = StringConcatenate(strL_Line_Name,IntegerToString(i));
      if(ObjectFind(ChartID(),strL_X_LineName)<0)
      if(create_T_Line(lngG_ID,strL_X_LineName,0,Time[intL_P0],High[intL_P0],Time[intL_P1],High[intL_P1],clrGold,head_style))
      {
         ObjectSetInteger(lngG_ID,strL_X_LineName,OBJPROP_RAY_RIGHT,true);
         ObjectSetInteger(lngG_ID,strL_X_LineName,OBJPROP_SELECTABLE,true); 
         ObjectSetInteger(lngG_ID,strL_X_LineName,OBJPROP_SELECTED,true); 
         ObjectSetInteger(lngG_ID,strL_X_LineName,OBJPROP_HIDDEN,false);          
         return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
bool show_T_Line_On()
{ 
   for(int i=0;i<ObjectsTotal(ChartID(),0,OBJ_TREND);i++)
   {
      string strL_Name = ObjectName(ChartID(),i,0,OBJ_TREND);
            if(StringSubstr(strL_Name,0,3) == "TL " || StringSubstr(strL_Name,0,5) == "Trend")
      if(ObjectGetInteger(lngG_ID,strL_Name,OBJPROP_COLOR) == clrNONE)  
         ObjectSetInteger(lngG_ID,strL_Name,OBJPROP_COLOR,clrGold);
      
   }
 
   return true;
}
//+------------------------------------------------------------------+
bool show_T_Line_Off()
{  
   string strL_Name;
   
   for(int i=0;i<ObjectsTotal(ChartID(),0,OBJ_TREND);i++)
   {
      strL_Name = ObjectName(ChartID(),i,0,OBJ_TREND);
            if(StringSubstr(strL_Name,0,3) == "TL " || StringSubstr(strL_Name,0,5) == "Trend")
      {
         ObjectSetInteger(lngG_ID,strL_Name,OBJPROP_COLOR,clrNONE);
         ObjectSetInteger(lngG_ID,strL_Name,OBJPROP_SELECTED,false);
      }
   }
 
   return true;
}
//+------------------------------------------------------------------+
bool check_TL_Off()
{
   for(int i=0;i<ObjectsTotal(ChartID(),0,OBJ_TREND);i++)
   {
      string strL_Name = ObjectName(ChartID(),i,0,OBJ_TREND);
            if(StringSubstr(strL_Name,0,3) == "TL " || StringSubstr(strL_Name,0,5) == "Trend")
         return true;
   }  
   return false;
}
//+------------------------------------------------------------------+
bool delete_T_Line()
{
   //20190524 kasuje linie trendu
   
   bool blnL_f = true;
   int intL_p = 0, intL_pp = 0;
   while(blnL_f && !IsStopped()&& intL_p<100) 
   { 
      intL_pp++;
      blnL_f = false;
      for(int i=0;i<ObjectsTotal(ChartID(),0,OBJ_TREND);i++)
      {
            string strL_Name = ObjectName(ChartID(),i,0,OBJ_TREND);
            if(StringSubstr(strL_Name,0,3) == "TL " || StringSubstr(strL_Name,0,5) == "Trend")
            {
               ObjectDelete(strL_Name);
               blnL_f = true;
               intL_p++;
            }
      }
   }
   //Alert("Wykasowałem  = ", intL_p," linii trendu z prefixem <<TL >> w ", intL_pp," przelotach");
   
   return true;
}
////-----------------------------------------------------+
//void hide_TL()
//{
////   int intL_ObjCount = ObjectsTotal();
////   
////      for(
////   
////   //ObjectsTotal(ChartID(),0,OBJ_TREND);
////   Alert("ilośćlinii trendu = ",intL_ObjCount);
//
//
//   //ArrayResize(col_TL_Nazwy,     intL_ObjCount);
//   //ArrayResize(col_TL_Kolory,    intL_ObjCount);
//   //ArrayResize(col_TL_Style,     intL_ObjCount);
//   //ArrayResize(col_TL_Grubosci,  intL_ObjCount);
//
//   
////   for(int i=0;i<intL_ObjCount;i++)
////   {
////      ArrayResize(col_TL_Nazwy,     i+1); col_TL_Nazwy[i] = ObjectName(i); 
////      ArrayResize(col_TL_Kolory,    i+1); col_TL_Nazwy[i] = ObjectName(i); 
////      ArrayResize(col_TL_Style,     i+1); col_TL_Nazwy[i] = ObjectName(i); 
////      ArrayResize(col_TL_Grubosci,  i+1); col_TL_Nazwy[i] = ObjectName(i); 
////   
////   }
//}
////+------------------------------------------------------------------+
////+            pierwsza klasa                                        +
////+------------------------------------------------------------------+
//class Harmonic_ABCD 
//{
//   public:
//      int         pnt_A_idx;    
//      int         pnt_B_idx;
//      int         pnt_C_idx;
//      int         pnt_D_idx;
//            
//      //int         dst_AD;
//      int         dst_BD;
//      int         dst_CD;
//      
//   public:
//      int dst_AB()
//      {
//         return pnt_A_idx - pnt_B_idx;
//      }
//      int dst_AC()
//      {
//         return pnt_A_idx - pnt_C_idx;
//      }
//      int dst_BC()
//      {
//         return pnt_B_idx - pnt_C_idx;
//      }
//   
//   public:
//      void CalculatePoints()
//      {
//
//      }
//
//};
////+------------------------------------------------------------------+
////+            próby rozwojowe                                       +
////+------------------------------------------------------------------+
//double Get_FiboLevel_Price (string Nazwa, int WhichLevel)
//{
//   double Level_Val=-1;
//
//   double dblL_Level = ObjectGetDouble(ChartID(),Nazwa,OBJPROP_LEVELVALUE,WhichLevel);
//   double dblL_0 = ObjectGetDouble(ChartID(),Nazwa,OBJPROP_PRICE,0);
//   double dblL_1 = ObjectGetDouble(ChartID(),Nazwa,OBJPROP_PRICE,1);
// 
//   if(dblL_1>dblL_0) Level_Val = dblL_1-(dblL_1-dblL_0)*dblL_Level;
//   if(dblL_1<dblL_0) Level_Val = dblL_1+(dblL_0-dblL_1)*dblL_Level;
//   
//   return Level_Val;
//
//   //skopiowane
//   //double fiboPrice1=ObjectGet("XIT_FIBO",OBJPROP_PRICE1);
//   //double fiboPrice2=ObjectGet("XIT_FIBO",OBJPROP_PRICE2);
//   //
//   
//}
//
//
//
//
//
//
//double KeyOfTheDay()
//{
////20180511 zwraca 
//
//   double dblL_Open = iOpen(NULL,PERIOD_D1,0);
//   double dblL_High = iHigh(NULL,PERIOD_D1,0);
//   double dblL_Low  = iLow(NULL,PERIOD_D1,0);
//   return (dblL_Open + dblL_High + dblL_Low)/3;
//}
//
////-------------------------------------------------------------------+
///// odpady
////+------------------------------------------------------------------+
//
////void zzz_Pisz(const int i,const ENUM_HorL HorL,const int PrevIdx)
////{
////   int intL_Prawy = i-(inp_Zakres-1);
////   if(intL_Prawy<0) intL_Prawy = 0;   
////
////   int intL_HH_Backword = iHighest(NULL,0,MODE_HIGH,inp_Zakres,i);
////   int intL_HH_Forward  = iHighest(NULL,0,MODE_HIGH,inp_Zakres,intL_Prawy);
////   int intL_LL_Backword = iLowest(NULL,0,MODE_LOW,inp_Zakres,i);
////   int intL_LL_Forward  = iLowest(NULL,0,MODE_LOW,inp_Zakres,intL_Prawy);
////   
//   
//   string            strL_NAME;
//   string            strL_Opis;
//   double            dblL_Price        = High[0];
//   ENUM_ANCHOR_POINT enm_AnchorPoint   = ANCHOR_LEFT_UPPER;
//   int               intL_Angle        = 0;
//   
//   if(HorL == hol_High)
//   {
//      strL_Opis = StringConcatenate("i:",i,"|B:",intL_HH_Backword,"|F:",intL_HH_Forward," Prev=",PrevIdx);
//      strL_NAME = StringConcatenate("Opis ",i,"+H");
//      dblL_Price = High[i];
//      enm_AnchorPoint = ANCHOR_LEFT_LOWER;
//      intL_Angle = 90;
//   }
//   else if (HorL == hol_Low)
//   {
//      strL_Opis = StringConcatenate("i:",i,"|B:",intL_LL_Backword,"|F:",intL_LL_Forward," Prev=",PrevIdx);
//      strL_NAME = StringConcatenate("Opis ",i,"+L");
//      dblL_Price = Low[i];
//      enm_AnchorPoint = ANCHOR_LEFT_UPPER;
//      intL_Angle = 270;         
//   }
//   
//   CreateText(ChartID(),strL_NAME+"_H",0,Time[i],dblL_Price,strL_Opis,clrSilver,enm_AnchorPoint,"Tahoma",10,intL_Angle);
//}
////+------------------------------------------------------------------+
//int Point_LL()
//{
//   dirG_Trend = Price_Trend();
//   intG_P_BS  = Point_BS();
//   
//   int i = Point_PO();
//   bool blnL_Found=false;
//   
//   while(!blnL_Found && i<=intG_P_BS && !IsStopped())
//   {
//      i++;
//      if (  (dirG_Trend == dir_long  && i == iLowest(NULL,0,MODE_LOW,18,i))   || 
//            (dirG_Trend == dir_short && i == iHighest(NULL,0,MODE_HIGH,18,i)) )
//      {
//         blnL_Found = true;
//         return i;
//      }
//   }
//   
//   //zwraca punkt bs, gdy nie moze znalezc LL
//   return(intG_P_BS);
//}

   //display ellliott letters
   //string strL_col_n;
   //string strL_ext;
   //string strL_Name;
   //int intL_size=ArraySize(col_fale_RomanBracekt)-1; 
   //for(int i=0;i<=intL_size;i++)
   //{
      //piervsza seria
      //string   strL_1_font    = "Arial Narrow";
      //int      intL_1_fontSize= 10;
      //color    clrL_1_color   = clrOrange;
      //strL_col_n = col_fale_RomanBracekt[i];
      //strL_ext = "RomanInBrackets";
      //strL_Name= "el"  + strL_ext + strL_col_n;
      //if(ObjectFind(lngG_ID,strL_Name)>-1)
      //do
      //{
      //   strL_Name = strL_Name + IntegerToString(MathRand());//strL_ext;
      //}
      //while(ObjectFind(lngG_ID,strL_Name)>-1 && !IsStopped());
      //create_Text(lngG_ID,strL_Name,0,Time[intL_Bar_First+(intL_size-i)*intL_Step],dlbL_Gdzie_1,strL_col_n,strL_1_font,intL_1_fontSize,clrL_1_color,0,ANCHOR_LEFT_UPPER,false,true,false);
      
      ////druga seria
      //string   strL_2_font    = "Arial";
      //int      intL_2_fontSize= 12;
      //color    clrL_2_color   = clrOrange;
      //strL_col_n = col_fale_Roman[i];     
      //strL_ext = "Roman";
      //strL_Name= "el"  + strL_ext + strL_col_n;
      //if(ObjectFind(lngG_ID,strL_Name)>-1)
      //do
      //{
      //   strL_Name = strL_Name + IntegerToString(MathRand());//strL_ext;
      //}
      //while(ObjectFind(lngG_ID,strL_Name)>-1 && !IsStopped());
      //create_Text(lngG_ID,strL_Name,0,Time[intL_Bar_First+(intL_size-i)*intL_Step],dlbL_Gdzie_2,strL_col_n,strL_2_font,intL_2_fontSize,clrL_2_color,0,ANCHOR_LEFT_UPPER,false,true,false);
      
//      //trzecia seria
//      string   strL_3_font    = "Arial Black";      
//      int      intL_3_fontSize= 12;
//      color    clrL_3_color   = clrPlum;
//      strL_col_n = col_fale_Small[i];                 
//      strL_ext = "SmallCaps";
//      strL_Name= "el"  + strL_ext + strL_col_n;
//      if(ObjectFind(lngG_ID,strL_Name)>-1)
//      do
//      {
//         strL_Name = strL_Name + IntegerToString(MathRand());//strL_ext;
//      }
//      while(ObjectFind(lngG_ID,strL_Name)>-1 && !IsStopped());
//      create_Text(lngG_ID,strL_Name,0,Time[intL_Bar_First+(intL_size-i)*intL_Step],dlbL_Gdzie_3,strL_col_n,strL_3_font,intL_3_fontSize,clrL_3_color,0,ANCHOR_LEFT_UPPER,false,true,false);
//      
//      //czwarta seria      
//      string   strL_4_font    = "Arial Black";
//      int      intL_4_fontSize= 14;
//      color    clrL_4_color   = clrMagenta;
//      strL_col_n = col_fale_Capital[i];           
//      strL_ext = "Capitals";
//      strL_Name= "el"  + strL_ext + strL_col_n;
//      if(ObjectFind(lngG_ID,strL_Name)>-1)
//      do
//      {
//         strL_Name = strL_Name + IntegerToString(MathRand());//strL_ext;
//      }
//      while(ObjectFind(lngG_ID,strL_Name)>-1 && !IsStopped());  
//      create_Text(lngG_ID,strL_Name,0,Time[intL_Bar_First+(intL_size-i)*intL_Step],dlbL_Gdzie_4,strL_col_n,strL_4_font,intL_4_fontSize,clrL_4_color,0,ANCHOR_LEFT_UPPER,false,true,false);
//
//
      ////piąta seria      
      //string   strL_5_font    = "Arial Black";
      //int      intL_5_fontSize= 16;
      //color    clrL_5_color   = clrAqua;
      //strL_col_n = col_fale_Capital[i];           
      //strL_ext = "Capitals+";
      //strL_Name= "el"  + strL_ext + strL_col_n;
      //if(ObjectFind(lngG_ID,strL_Name)>-1)
      //do
      //{
      //   strL_Name = strL_Name + IntegerToString(MathRand());//strL_ext;
      //}
      //while(ObjectFind(lngG_ID,strL_Name)>-1 && !IsStopped());  
      //create_Text(lngG_ID,strL_Name,0,Time[intL_Bar_First+(intL_size-i)*intL_Step],dlbL_Gdzie_5,strL_col_n,strL_5_font,intL_5_fontSize,clrL_5_color,0,ANCHOR_LEFT_UPPER,false,true,false);
     
      ////szósta seria      
      //string   strL_6_font    = "Arial Black";
      //int      intL_6_fontSize= 18;
      //color    clrL_6_color   = clrDeepSkyBlue;
      //strL_col_n = col_fale_CapitalBracket[i];                       
      //strL_ext = "BigCaps";
      //strL_Name= "el"  + strL_ext + strL_col_n;
      //if(ObjectFind(lngG_ID,strL_Name)>-1)
      //do
      //{
      //   strL_Name = strL_Name + IntegerToString(MathRand());//strL_ext;
      //}
      //while(ObjectFind(lngG_ID,strL_Name)>-1 && !IsStopped());
      //create_Text(lngG_ID,strL_Name,0,Time[intL_Bar_First+(intL_size-i)*intL_Step],dlbL_Gdzie_6,strL_col_n,strL_6_font,intL_6_fontSize,clrL_6_color,0,ANCHOR_LEFT_UPPER,false,true,false);

      ////siódma seria      
      //string   strL_7_font    = "Century Gothic";
      //int      intL_7_fontSize= 14;
      //color    clrL_7_color   = clrSilver;
      //strL_col_n = col_fale_ALT[i];                       
      //strL_ext = "Mad";
      //strL_Name= "el"  + strL_ext + strL_col_n;
      //if(ObjectFind(lngG_ID,strL_Name)>-1)
      //do
      //{
      //   strL_Name = strL_Name + IntegerToString(MathRand());//strL_ext;
      //}
      //while(ObjectFind(lngG_ID,strL_Name)>-1 && !IsStopped());
      //create_Text(lngG_ID,strL_Name,0,Time[intL_Bar_First+(intL_size-i)*intL_Step],dlbL_Gdzie_7,strL_col_n,strL_7_font,intL_7_fontSize,clrL_7_color,0,ANCHOR_LEFT_UPPER,false,true,false);
   //}
   
   
   
   
////+------------------------------------------------------------------+ 
////| Create Fibonacci Time Zones by the given coordinates             | 
////+------------------------------------------------------------------+ 
//bool CreateFiboTimes(const long            chart_ID=0,        // chart's ID 
//                     const string          name="FiboTimes",  // object name 
//                     const int             sub_window=0,      // subwindow index  
//                     datetime              time1=0,           // first point time 
//                     double                price1=0,          // first point price 
//                     datetime              time2=0,           // second point time 
//                     double                price2=0,          // second point price 
//                     const color           clr=clrRed,        // object color 
//                     const ENUM_LINE_STYLE style=STYLE_SOLID, // object line style 
//                     const int             width=1,           // object line width 
//                     const bool            back=false,        // in the background 
//                     const bool            selection=true,    // highlight to move 
//                     const bool            hidden=true,       // hidden in the object list 
//                     const long            z_order=0)         // priority for mouse click 
//{ 
//   //--- reset the error value 
//   ResetLastError(); 
//   
//   //odrzuca sytuacje, gdy obiekt już istnieje i nie ma sensu go na nowo tworzyć
//   if(ObjectFind(chart_ID,name)>=0) return true;
//   
//   //kasowanie jesli juz zostal stworzony wczesniej
//   ObjectDelete(chart_ID,name); 
//   //create Fibonacci Time Zones by the given coordinates 
//   if(!ObjectCreate(chart_ID,name,OBJ_FIBOTIMES,sub_window,time1,price1,time2,price2)) 
//     { 
//      Print(__FUNCTION__, 
//            ": failed to create \"Fibonacci Time Zones\"! Error code = ",GetLastError()); 
//      return(false); 
//     } 
////--- set color 
//   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
////--- set line style 
//   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
////--- set line width 
//   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
////--- display in the foreground (false) or background (true) 
//   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
////--- enable (true) or disable (false) the mode of highlighting the channel for moving 
////--- when creating a graphical object using ObjectCreate function, the object cannot be 
////--- highlighted and moved by default. Inside this method, selection parameter 
////--- is true by default making it possible to highlight and move the object 
//   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
//   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
////--- hide (true) or display (false) graphical object name in the object list 
//   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
////--- set the priority for receiving the event of a mouse click in the chart 
//   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
////--- successful execution 
//   return(true); 
//  }    


////+------------------------------------------------------------------+ 
////| Creating Text object                                             | 
////+------------------------------------------------------------------+ 
//bool CreateText(const long              chart_ID=0,               // chart's ID 
//                const string            name="Text",              // object name 
//                const int               sub_window=0,             // subwindow index 
//                datetime                time=0,                   // anchor point time 
//                double                  price=0,                  // anchor point price 
//                const string            text="Text",              // the text itself 
//                const color             clr=clrRed,               // color 
//                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type 
//                const string            font="Arial",             // font 
//                const int               font_size=8,              // font size 
//                const double            angle=0.0,                // text slope 
//                const bool              back=false,               // in the background 
//                const bool              selection=false,          // highlight to move 
//                const bool              hidden=true,              // hidden in the object list 
//                const long              z_order=0)                // priority for mouse click 
//{ 
////--- set anchor point coordinates if they are not set 
//   //ChangeTextEmptyPoint(time,price); 
//   
//   //odrzuca sytuacje, gdy obiekt już istnieje i nie ma sensu go na nowo tworzyć
//   if(ObjectFind(chart_ID,name)>=0) return true;
//   
////--- reset the error value 
//   ResetLastError(); 
////--- create Text object 
//   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price)) 
//     { 
//      Print(__FUNCTION__, 
//            ": failed to create \"Text\" object! Error code = ",GetLastError()); 
//      return(false); 
//     } 
////--- set the text 
//   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text); 
////--- set text font 
//   ObjectSetString(chart_ID,name,OBJPROP_FONT,font); 
////--- set font size 
//   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size); 
////--- set the slope angle of the text 
//   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle); 
////--- set anchor type 
//   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor); 
////--- set color 
//   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
////--- display in the foreground (false) or background (true) 
//   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
////--- enable (true) or disable (false) the mode of moving the object by mouse 
//   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
//   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
////--- hide (true) or display (false) graphical object name in the object list 
//   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
////--- set the priority for receiving the event of a mouse click in the chart 
//   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
////--- successful execution 
//   return(true); 
//} 