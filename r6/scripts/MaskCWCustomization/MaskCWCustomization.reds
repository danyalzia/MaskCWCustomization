module MaskCWCustomization

class MaskCWCustomization {
  public static func DeactivatePreventionUptoFiveStars() -> Bool = false
  public static func AllowInCombat() -> Bool = false
}

@replaceMethod(PreventionSystem)
public static func UseCWMask(game : GameInstance) -> Void {
    let ps: ref<PreventionSystem> = GameInstance.GetScriptableSystemsContainer(game).Get(n"PreventionSystem") as PreventionSystem;
    if (Equals(ps.GetHeatStage(), EPreventionHeatStage.Heat_5) && !MaskCWCustomization.DeactivatePreventionUptoFiveStars())
    {
        return;
    }
    if ((!ps.IsChasingPlayer() || Equals(ps.GetStarState(), EStarState.Active)) && !MaskCWCustomization.AllowInCombat())
    {
        return;
    }
    let preventionForceDeescalateRequest = new PreventionForceDeescalateRequest();
    preventionForceDeescalateRequest.fakeBlinkingDuration = TweakDBInterface.GetFloat(t"PreventionSystem.setup.forcedDeescalationUIStarsBlinkingDurationSeconds", 4.0);
    preventionForceDeescalateRequest.telemetryInfo = "MaskCyberware";
    ps.QueueRequest(preventionForceDeescalateRequest);
}

@replaceMethod(ChargedHotkeyItemGadgetController)
protected func ResolveState() -> Void {
    if( this.IsCyberwareActive() )
    {
        this.GetRootWidget().SetState( n"ActiveUninterruptible" );
    }
    else if( Equals(this.GetItemType( this.m_currentItem.ID, n"" ), this.c_cwMaskKey) && Equals(this.m_currentCombatState, gamePSMCombat.InCombat) && !MaskCWCustomization.AllowInCombat())
    {
        this.GetRootWidget().SetState( n"Unavailable" );
    }
    else if( this.IsInDefaultState() && ( this.m_currentProgress >= this.m_chargeThreshold ) )
    {
        this.GetRootWidget().SetState( n"Default" );
    }
    else
    {
        this.GetRootWidget().SetState( n"Unavailable" );
    }
}