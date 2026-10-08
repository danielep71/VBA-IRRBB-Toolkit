Attribute VB_Name = "TEST_DecayCases"
'==============================================================================
' TEST_DecayCases
'------------------------------------------------------------------------------
' PURPOSE
'   VBA implementations of the decay cases in docs/methodology/TEST_CASES.md.
'   Inputs and expected values come from TEST_DecayData, generated from
'   tests/fixtures/decay and tests/expected/decay (independent references).
'   Cases may call src/core directly (docs/REPOSITORY_STRUCTURE.md) and use
'   the facade where the contract is about the public boundary.
'==============================================================================
Option Explicit
Option Private Module

Private mExpected As Variant
Private mInputs As Variant


Public Sub TEST_RunDecayCase(ByVal caseId As String)
    If IsEmpty(mExpected) Then
        mExpected = TEST_DecayExpected()
        mInputs = TEST_DecayInputs()
    End If
    Select Case caseId
        Case "DEC-LOG-01": CaseLog
        Case "DEC-MPA-01": CaseMpa
        Case "DEC-PROF-01": CaseProfile
        Case "DEC-LIFE-01": CaseLife
        Case "DEC-CAP-01": CaseCap
        Case "DEC-E2E-01": CaseEndToEnd
        Case "DEC-ERR-01": CaseErrors
        Case "OOS-FREEZE-01": CaseFreeze
        Case "OOS-LEAK-01": CaseLeak
        Case "OOS-SCORE-01": CaseScore
        Case Else
            Err.Raise CORE_ERR_INPUT, "TEST_DecayCases.TEST_RunDecayCase", "No decay implementation for " & caseId & "."
    End Select
End Sub


'==============================================================================
' Cases
'==============================================================================
Private Sub CaseLog()
    Const ID As String = "DEC-LOG-01"
    Dim dates() As Date, bal() As Double, g() As Double, i As Long, pos() As Long
    Dim mu As Double, sigma As Double, kappa() As Double, resid() As Double

    TEST_FixtureShort dates, bal
    ReDim g(1 To UBound(bal) - 1)
    For i = 2 To UBound(bal)
        g(i - 1) = Log(bal(i)) - Log(bal(i - 1))
        Check ID, "g[" & (i - 2) & "]", g(i - 1)
    Next i
    ReDim pos(1 To 1)
    CORE_DecayEstimate g, pos, 0, mu, sigma, kappa, resid
    Check ID, "nobreak_mu", mu
    Check ID, "nobreak_sigma", sigma

    pos(1) = 0
    For i = 2 To UBound(dates)
        If dates(i) = InputValue(ID, "break_dates[0]") Then pos(1) = i - 1
    Next i
    TEST_AssertTrue ID, "break date maps to a log change", pos(1) > 0
    CORE_DecayEstimate g, pos, 1, mu, sigma, kappa, resid
    Check ID, "break_mu", mu
    Check ID, "break_sigma", sigma
    Check ID, "break_kappa", kappa(1)
    For i = 1 To UBound(resid)
        Check ID, "break_resid[" & (i - 1) & "]", resid(i)
    Next i
End Sub


Private Sub CaseMpa()
    Const ID As String = "DEC-MPA-01"
    Dim z As Double, mpa() As Double, runoff() As Double, median() As Double, h As Long
    Dim nonCore As Double, life As Double, coreLife As Double
    z = CORE_NormSInv(1 - InputValue(ID, "confidence"))
    Check ID, "z", z
    CORE_DecayProfile InputValue(ID, "b0"), InputValue(ID, "mu_star"), InputValue(ID, "sigma"), z, _
                      CLng(InputValue(ID, "cutoff")), mpa, runoff, median, nonCore, life, coreLife
    For h = 0 To UBound(mpa)
        Check ID, "mpa[" & h & "]", mpa(h)
    Next h
End Sub


Private Sub CaseProfile()
    Const ID As String = "DEC-PROF-01"
    Dim mpa() As Double, runoff() As Double, median() As Double, h As Long, total As Double, mono As Boolean
    Dim nonCore As Double, life As Double, coreLife As Double
    HandProfile ID, mpa, runoff, median, nonCore, life, coreLife
    mono = True
    For h = 0 To UBound(mpa)
        Check ID, "mpa[" & h & "]", mpa(h)
        If h > 0 Then
            If mpa(h) > mpa(h - 1) Then mono = False
        End If
    Next h
    For h = 1 To UBound(runoff)
        Check ID, "runoff[" & (h - 1) & "]", runoff(h)
        total = total + runoff(h)
    Next h
    Check ID, "remainder", mpa(UBound(mpa))
    Check ID, "sum", total + mpa(UBound(mpa))
    TEST_AssertTrue ID, "MPA non-increasing", mono
End Sub


Private Sub CaseLife()
    Const ID As String = "DEC-LIFE-01"
    Dim mpa() As Double, runoff() As Double, median() As Double, nonCore As Double, life As Double, coreLife As Double
    HandProfile ID, mpa, runoff, median, nonCore, life, coreLife
    Check ID, "mean_life", life
    Check ID, "core_mean_life", coreLife
    Check ID, "noncore_share", nonCore
End Sub


Private Sub CaseCap()
    Const ID As String = "DEC-CAP-01"
    Dim c As Long, p As String, mpa() As Double, runoff() As Double, median() As Double
    Dim nonCore As Double, life As Double, coreLife As Double, ov() As Double, ovInfo() As Double
    Dim ovLabel As String, h As Long, total As Double
    For c = 1 To 3
        p = "case" & c & "."
        CORE_DecayProfile InputValue(ID, p & "b0"), InputValue(ID, p & "mu_star"), InputValue(ID, p & "sigma"), _
                          InputValue(ID, p & "z"), CLng(InputValue(ID, p & "cutoff")), mpa, runoff, median, _
                          nonCore, life, coreLife
        IRRBB_DecayOverlay CStr(InputValue(ID, p & "segment")), mpa, ov, ovInfo, ovLabel
        total = 0
        For h = 0 To UBound(ov)
            Check ID, p & "buckets[" & h & "]", ov(h)
            total = total + ov(h)
        Next h
        Check ID, p & "scale", ovInfo(IRRBB_OV_SCALE)
        Check ID, p & "share_applied", ovInfo(IRRBB_OV_SHARE_APPLIED)
        Check ID, p & "core_share", ovInfo(IRRBB_OV_CORE_SHARE)
        Check ID, p & "core_mean_life_in", ovInfo(IRRBB_OV_CORE_MEANLIFE_IN)
        Check ID, p & "cutoff", ovInfo(IRRBB_OV_CUTOFF)
        Check ID, p & "mat_applied", ovInfo(IRRBB_OV_MAT_APPLIED)
        Check ID, p & "core_mean_life", ovInfo(IRRBB_OV_CORE_MEANLIFE)
        Check ID, p & "overnight", ovInfo(IRRBB_OV_OVERNIGHT)
        Check ID, p & "share_cap", ovInfo(IRRBB_OV_CORE_SHARE_CAP)
        Check ID, p & "mat_cap", ovInfo(IRRBB_OV_MAT_CAP)
        TEST_AssertNear ID, p & "overlay sums to B0", total, mpa(0), "abs", 0.00000001
        TEST_AssertTrue ID, p & "bucket 1 empty (non-core overnight)", ov(1) = 0
        TEST_AssertTrue ID, p & "label marks REG-2 provisional", InStr(1, ovLabel, "REG-2, unverified]: provisional") > 0
    Next c
End Sub


Private Sub CaseEndToEnd()
    Const ID As String = "DEC-E2E-01"
    Dim dates() As Date, bal() As Double, fit() As Double, mpa() As Double, runoff() As Double
    Dim median() As Double, kappa() As Double, resid() As Double, diag() As Double
    Dim ov() As Double, ovInfo() As Double, ovLabel As String, pairs() As Double, exceed() As Double, sm() As Double
    Dim h As Long

    FitRetTx dates, bal, fit, mpa, runoff, median, kappa, resid, diag
    Check ID, "n", fit(IRRBB_DF_N)
    Check ID, "mu_hat", fit(IRRBB_DF_MU_HAT)
    Check ID, "kappa", kappa(1)
    Check ID, "sigma", fit(IRRBB_DF_SIGMA)
    Check ID, "z", fit(IRRBB_DF_Z)
    Check ID, "mu_star", fit(IRRBB_DF_MU_STAR)
    Check ID, "b0", fit(IRRBB_DF_B0)
    Check ID, "mpa1", mpa(1)
    Check ID, "mpa12", mpa(12)
    Check ID, "mpa60", mpa(60)
    Check ID, "mpa120", mpa(120)
    Check ID, "noncore_share", fit(IRRBB_DF_NONCORE_SHARE)
    Check ID, "mean_life", fit(IRRBB_DF_MEANLIFE)
    Check ID, "core_mean_life", fit(IRRBB_DF_CORE_MEANLIFE)
    Check ID, "lb_q", diag(IRRBB_DD_LB_Q)
    Check ID, "lb_p", diag(IRRBB_DD_LB_P)
    Check ID, "jb", diag(IRRBB_DD_JB)
    Check ID, "jb_p", diag(IRRBB_DD_JB_P)
    Check ID, "skew", diag(IRRBB_DD_SKEW)
    Check ID, "kurt", diag(IRRBB_DD_KURT)
    Check ID, "emp_q", diag(IRRBB_DD_EMP_Q)
    TEST_AssertTrue ID, "fit origin is the estimation end", CDate(fit(IRRBB_DF_ORIGIN)) = InputValue(ID, "est_end")

    IRRBB_DecayOverlay "RET_TX", mpa, ov, ovInfo, ovLabel
    Check ID, "ov_scale", ovInfo(IRRBB_OV_SCALE)
    Check ID, "ov_cutoff", ovInfo(IRRBB_OV_CUTOFF)
    Check ID, "ov_overnight", ovInfo(IRRBB_OV_OVERNIGHT)
    Check ID, "ov_core_mean_life", ovInfo(IRRBB_OV_CORE_MEANLIFE)

    IRRBB_DecayBacktest dates, bal, fit, InputValue(ID, "test_end"), CLng(InputValue(ID, "max_horizon")), _
                        pairs, exceed, sm
    Check ID, "bt_origins", sm(IRRBB_BT_ORIGINS)
    Check ID, "bt_pairs", sm(IRRBB_BT_PAIRS)
    Check ID, "bt_exceed", sm(IRRBB_BT_EXCEED)
    Check ID, "bt_rate", sm(IRRBB_BT_RATE)
    For h = 1 To UBound(pairs)
        Check ID, "bt_pairs_by_h[" & (h - 1) & "]", pairs(h)
        Check ID, "bt_exceed_by_h[" & (h - 1) & "]", exceed(h)
    Next h

    ' The facade layouts must match the core layouts they publish.
    TEST_AssertTrue ID, "fit layout matches core", IRRBB_DF_FIRST_DATE = CORE_DF_FIRST_DATE And _
                    IRRBB_DF_CUTOFF = CORE_DF_CUTOFF And IRRBB_DF_MU_STAR = CORE_DF_MU_STAR And _
                    UBound(fit) = CORE_DF_COUNT
    TEST_AssertTrue ID, "diagnostics layout matches core", IRRBB_DD_NORM_Q = CORE_DD_NORM_Q And _
                    IRRBB_DD_EMP_Q = CORE_DD_EMP_Q And UBound(diag) = CORE_DD_COUNT
    TEST_AssertTrue ID, "overlay layout matches core", IRRBB_OV_OVERNIGHT = CORE_OV_OVERNIGHT And _
                    IRRBB_OV_SCALE = CORE_OV_SCALE And UBound(ovInfo) = CORE_OV_COUNT
    TEST_AssertTrue ID, "backtest layout matches core", IRRBB_BT_MAX_H = CORE_BT_MAX_H And _
                    IRRBB_BT_RATE = CORE_BT_RATE And UBound(sm) = CORE_BT_COUNT
End Sub


Private Sub CaseErrors()
    Const ID As String = "DEC-ERR-01"
    Dim dates() As Date, bal() As Double, d2() As Date, b2() As Double, i As Long
    Dim mpa() As Double, ov() As Double, ovInfo() As Double, ovLabel As String

    TEST_FixtureRetTx dates, bal
    TEST_AssertError ID, "35 log changes are below the minimum", _
                     FitError("RET_TX", "EUR", dates, bal, DateSerial(2012, 1, 31), DateSerial(2014, 12, 31), Empty, 0.99, 120), _
                     CORE_ERR_SAMPLE
    TEST_AssertError ID, "36 log changes are accepted", _
                     FitError("RET_TX", "EUR", dates, bal, DateSerial(2012, 1, 31), DateSerial(2015, 1, 31), Empty, 0.99, 120), 0
    TEST_AssertError ID, "unknown segment", _
                     FitError("RET_XX", "EUR", dates, bal, DateSerial(2012, 1, 31), DateSerial(2022, 12, 31), Empty, 0.99, 120), _
                     CORE_ERR_INPUT
    TEST_AssertError ID, "currency outside the run allowlist", _
                     FitError("RET_TX", "GBP", dates, bal, DateSerial(2012, 1, 31), DateSerial(2022, 12, 31), Empty, 0.99, 120), _
                     CORE_ERR_INPUT
    TEST_AssertError ID, "currency not ISO upper case", _
                     FitError("RET_TX", "eur", dates, bal, DateSerial(2012, 1, 31), DateSerial(2022, 12, 31), Empty, 0.99, 120), _
                     CORE_ERR_INPUT
    TEST_AssertError ID, "confidence of 1", _
                     FitError("RET_TX", "EUR", dates, bal, DateSerial(2012, 1, 31), DateSerial(2022, 12, 31), Empty, 1, 120), _
                     CORE_ERR_DOMAIN
    TEST_AssertError ID, "cutoff of 1 month", _
                     FitError("RET_TX", "EUR", dates, bal, DateSerial(2012, 1, 31), DateSerial(2022, 12, 31), Empty, 0.99, 1), _
                     CORE_ERR_INPUT
    TEST_AssertError ID, "break outside the window", _
                     FitError("RET_TX", "EUR", dates, bal, DateSerial(2012, 1, 31), DateSerial(2022, 12, 31), _
                              Array(DateSerial(2024, 3, 31)), 0.99, 120), CORE_ERR_INPUT
    TEST_AssertError ID, "break given as text is rejected", _
                     FitError("RET_TX", "EUR", dates, bal, DateSerial(2012, 1, 31), DateSerial(2022, 12, 31), _
                              Array("2020-03-31"), 0.99, 120), CORE_ERR_INPUT

    d2 = dates
    b2 = bal
    b2(50) = 0
    TEST_AssertError ID, "zero balance in the window", _
                     FitError("RET_TX", "EUR", d2, b2, DateSerial(2012, 1, 31), DateSerial(2022, 12, 31), Empty, 0.99, 120), _
                     CORE_ERR_DOMAIN
    d2 = dates
    b2 = bal
    d2(50) = d2(50) - 1
    TEST_AssertError ID, "date that is not a month end", _
                     FitError("RET_TX", "EUR", d2, b2, DateSerial(2012, 1, 31), DateSerial(2022, 12, 31), Empty, 0.99, 120), _
                     CORE_ERR_INPUT
    ReDim d2(1 To UBound(dates) - 1)
    ReDim b2(1 To UBound(dates) - 1)
    For i = 1 To UBound(d2)
        If i < 60 Then
            d2(i) = dates(i)
            b2(i) = bal(i)
        Else
            d2(i) = dates(i + 1)
            b2(i) = bal(i + 1)
        End If
    Next i
    TEST_AssertError ID, "missing month (gap) in the window", _
                     FitError("RET_TX", "EUR", d2, b2, DateSerial(2012, 1, 31), DateSerial(2022, 12, 31), Empty, 0.99, 120), _
                     CORE_ERR_INPUT

    ReDim mpa(0 To 3)
    mpa(0) = 100: mpa(1) = 90: mpa(2) = 95: mpa(3) = 80
    TEST_AssertError ID, "overlay rejects a non-monotone path", OverlayError("RET_TX", mpa), CORE_ERR_INVARIANT
    mpa(2) = 85
    TEST_AssertError ID, "overlay rejects an unknown segment", OverlayError("RET", mpa), CORE_ERR_INPUT
End Sub


Private Sub CaseFreeze()
    Const ID As String = "OOS-FREEZE-01"
    Dim dates() As Date, bal() As Double, fit() As Double, mpa() As Double, runoff() As Double
    Dim median() As Double, kappa() As Double, resid() As Double, diag() As Double
    Dim fit2() As Double, keep() As Double, pairs() As Double, exceed() As Double, sm() As Double
    Dim i As Long, same As Boolean

    FitRetTx dates, bal, fit, mpa, runoff, median, kappa, resid, diag
    keep = fit
    IRRBB_DecayBacktest dates, bal, fit, DateSerial(2025, 12, 31), 12, pairs, exceed, sm
    same = True
    For i = 1 To UBound(fit)
        If fit(i) <> keep(i) Then same = False
    Next i
    TEST_AssertTrue ID, "backtest leaves the frozen parameters unchanged", same

    For i = 1 To UBound(dates)
        If dates(i) > DateSerial(2022, 12, 31) Then bal(i) = bal(i) * 0.5
    Next i
    IRRBB_DecayFit "RET_TX", "EUR", dates, bal, DateSerial(2012, 1, 31), DateSerial(2022, 12, 31), _
                   Array(DateSerial(2020, 3, 31)), 0.99, 120, fit2, mpa, runoff, median, kappa, resid, diag
    same = True
    For i = 1 To UBound(fit)
        If fit2(i) <> keep(i) Then same = False
    Next i
    TEST_AssertTrue ID, "test-window data do not change the estimated parameters", same
End Sub


Private Sub CaseLeak()
    Const ID As String = "OOS-LEAK-01"
    Dim dates() As Date, bal() As Double, fit() As Double, mpa() As Double, runoff() As Double
    Dim median() As Double, kappa() As Double, resid() As Double, diag() As Double
    Dim p1() As Double, e1() As Double, s1() As Double, p2() As Double, e2() As Double, s2() As Double
    Dim i As Long, same As Boolean

    FitRetTx dates, bal, fit, mpa, runoff, median, kappa, resid, diag
    IRRBB_DecayBacktest dates, bal, fit, DateSerial(2024, 12, 31), 12, p1, e1, s1
    For i = 1 To UBound(dates)
        If dates(i) > DateSerial(2024, 12, 31) Then bal(i) = bal(i) * 0.1
    Next i
    IRRBB_DecayBacktest dates, bal, fit, DateSerial(2024, 12, 31), 12, p2, e2, s2
    same = True
    For i = 1 To UBound(p1)
        If p1(i) <> p2(i) Or e1(i) <> e2(i) Then same = False
    Next i
    For i = 1 To UBound(s1)
        If s1(i) <> s2(i) Then same = False
    Next i
    TEST_AssertTrue ID, "scores unchanged when data after the test window change", same
End Sub


Private Sub CaseScore()
    Const ID As String = "OOS-SCORE-01"
    Dim dates() As Date, bal() As Double, fit() As Double, i As Long, n As Long
    Dim pairs() As Double, exceed() As Double, sm() As Double
    n = 7
    ReDim dates(1 To n)
    ReDim bal(1 To n)
    For i = 1 To n
        dates(i) = InputValue(ID, "dates[" & (i - 1) & "]")
        bal(i) = InputValue(ID, "balances[" & (i - 1) & "]")
    Next i
    ReDim fit(1 To CORE_DF_COUNT)
    fit(CORE_DF_MU_STAR) = InputValue(ID, "mu_star")
    fit(CORE_DF_SIGMA) = InputValue(ID, "sigma")
    fit(CORE_DF_Z) = InputValue(ID, "z")
    fit(CORE_DF_CONFIDENCE) = InputValue(ID, "confidence")
    fit(CORE_DF_ORIGIN) = CDbl(CDate(InputValue(ID, "origin")))
    CORE_DecayBacktest dates, bal, fit, dates(n), CLng(InputValue(ID, "max_horizon")), pairs, exceed, sm
    For i = 1 To UBound(pairs)
        Check ID, "pairs_by_h[" & (i - 1) & "]", pairs(i)
        Check ID, "exceed_by_h[" & (i - 1) & "]", exceed(i)
    Next i
    Check ID, "origins", sm(CORE_BT_ORIGINS)
    Check ID, "pairs", sm(CORE_BT_PAIRS)
    Check ID, "exceed", sm(CORE_BT_EXCEED)
    Check ID, "rate", sm(CORE_BT_RATE)
End Sub


'==============================================================================
' Helpers
'==============================================================================
Private Sub FitRetTx(ByRef dates() As Date, ByRef bal() As Double, ByRef fit() As Double, ByRef mpa() As Double, _
                     ByRef runoff() As Double, ByRef median() As Double, ByRef kappa() As Double, _
                     ByRef resid() As Double, ByRef diag() As Double)
    Const ID As String = "DEC-E2E-01"
    TEST_FixtureRetTx dates, bal
    IRRBB_DecayFit CStr(InputValue(ID, "segment")), CStr(InputValue(ID, "currency")), dates, bal, _
                   InputValue(ID, "est_start"), InputValue(ID, "est_end"), Array(InputValue(ID, "break_dates[0]")), _
                   InputValue(ID, "confidence"), CLng(InputValue(ID, "cutoff")), fit, mpa, runoff, median, _
                   kappa, resid, diag
End Sub


Private Sub HandProfile(ByVal caseId As String, ByRef mpa() As Double, ByRef runoff() As Double, _
                        ByRef median() As Double, ByRef nonCore As Double, ByRef life As Double, _
                        ByRef coreLife As Double)
    CORE_DecayProfile InputValue(caseId, "b0"), InputValue(caseId, "mu_star"), InputValue(caseId, "sigma"), _
                      InputValue(caseId, "z"), CLng(InputValue(caseId, "cutoff")), mpa, runoff, median, _
                      nonCore, life, coreLife
End Sub


Private Function FitError(ByVal segment As String, ByVal currencyCode As String, ByRef dates() As Date, _
                          ByRef bal() As Double, ByVal estStart As Date, ByVal estEnd As Date, _
                          ByVal breaks As Variant, ByVal confidence As Double, ByVal cutoff As Long) As Long
    Dim fit() As Double, mpa() As Double, runoff() As Double, median() As Double
    Dim kappa() As Double, resid() As Double, diag() As Double
    On Error Resume Next
    IRRBB_DecayFit segment, currencyCode, dates, bal, estStart, estEnd, breaks, confidence, cutoff, _
                   fit, mpa, runoff, median, kappa, resid, diag
    FitError = Err.Number
    On Error GoTo 0
End Function


Private Function OverlayError(ByVal segment As String, ByRef mpa() As Double) As Long
    Dim ov() As Double, ovInfo() As Double, ovLabel As String
    On Error Resume Next
    IRRBB_DecayOverlay segment, mpa, ov, ovInfo, ovLabel
    OverlayError = Err.Number
    On Error GoTo 0
End Function


Private Sub Check(ByVal caseId As String, ByVal key As String, ByVal actual As Double)
    Dim i As Long
    For i = LBound(mExpected, 1) To UBound(mExpected, 1)
        If mExpected(i, 1) = caseId And mExpected(i, 2) = key Then
            TEST_AssertNear caseId, key, actual, CDbl(mExpected(i, 3)), CStr(mExpected(i, 4)), CDbl(mExpected(i, 5))
            Exit Sub
        End If
    Next i
    TEST_AssertTrue caseId, key & " has no registered expected value", False
End Sub


Private Function InputValue(ByVal caseId As String, ByVal key As String) As Variant
    Dim i As Long
    For i = LBound(mInputs, 1) To UBound(mInputs, 1)
        If mInputs(i, 1) = caseId And mInputs(i, 2) = key Then
            InputValue = mInputs(i, 3)
            Exit Function
        End If
    Next i
    Err.Raise CORE_ERR_INPUT, "TEST_DecayCases.InputValue", "No input " & key & " for " & caseId & "."
End Function
