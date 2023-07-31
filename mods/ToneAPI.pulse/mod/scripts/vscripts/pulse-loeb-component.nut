global function pulseRegisterWithLoeb

void function pulseRegisterWithLoeb()
{
    bool success = pulseGetData()
    loebSetLockedButton(Localize("#MENU_TITLE_STATS"), success)
}