Attribute VB_Name = "CORE_Codes"
'==============================================================================
' CORE_Codes
'------------------------------------------------------------------------------
' PURPOSE
'   Code lists of docs/methodology/DATA_CONTRACT.md used at the public
'   boundary: segment codes and the explicit, versioned run allowlist of
'   ISO 4217 currency codes. Three upper-case letters alone are not a valid
'   currency (DATA_CONTRACT.md, account panel).
'
' ALLOWLIST
'   Version CORE_CURRENCY_ALLOWLIST_VERSION covers the synthetic reference
'   data only (EUR, USD). Extending it needs reviewed configuration and
'   provenance; it does not claim to maintain the full ISO register.
'==============================================================================
Option Explicit
Option Private Module

Public Const CORE_CURRENCY_ALLOWLIST As String = "EUR,USD"
Public Const CORE_CURRENCY_ALLOWLIST_VERSION As String = "synthetic-2026-10-08"


'------------------------------------------------------------------------------
' CORE_IsSegmentCode: True for RET_TX, RET_NTX and WHS_NFC (exact, case-sensitive).
'------------------------------------------------------------------------------
Public Function CORE_IsSegmentCode(ByVal code As String) As Boolean
    Select Case code
        Case "RET_TX", "RET_NTX", "WHS_NFC"
            CORE_IsSegmentCode = True
        Case Else
            CORE_IsSegmentCode = False
    End Select
End Function


'------------------------------------------------------------------------------
' CORE_IsCurrencyAllowed: True when code is in CORE_CURRENCY_ALLOWLIST (exact).
'------------------------------------------------------------------------------
Public Function CORE_IsCurrencyAllowed(ByVal code As String) As Boolean
    If Len(code) <> 3 Or InStr(1, code, ",") > 0 Then
        CORE_IsCurrencyAllowed = False
    Else
        CORE_IsCurrencyAllowed = InStr(1, "," & CORE_CURRENCY_ALLOWLIST & ",", "," & code & ",", vbBinaryCompare) > 0
    End If
End Function
