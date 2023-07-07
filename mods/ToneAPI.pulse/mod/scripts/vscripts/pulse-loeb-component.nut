global function pulseRegisterWithLoeb
global function pulseLoebFunc

void function pulseRegisterWithLoeb()
{
    loebLogMod(pulseLoebFunc())
}

void function pulseLoebFunc()
{
    print("func called")
    GetStats()
}

void function GetStats()
{
    loebSetLockedButton(Localize("#MENU_TITLE_STATS"), pulseGetData())
}