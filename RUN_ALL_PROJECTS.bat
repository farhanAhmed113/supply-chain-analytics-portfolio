@echo off
title Supply Chain Analytics Portfolio Runner
color 0A
echo ===============================================================================
echo                SUPPLY CHAIN ANALYTICS PORTFOLIO RUNNER
echo                  (Zero Setup - Automated SQL Execution)
echo ===============================================================================
echo.

echo [1/3] Running Project 1: Inventory Management ^& Stock Optimization...
python "%~dp0project_1_inventory_optimization\run_project_1.py"
echo.

echo [2/3] Running Project 2: Supplier Performance ^& Strategic Procurement...
python "%~dp0project_2_supplier_performance\run_project_2.py"
echo.

echo [3/3] Running Project 3: Logistics ^& Freight Shipment Tracking...
python "%~dp0project_3_logistics_tracking\run_project_3.py"
echo.

echo ===============================================================================
echo ALL 3 SUPPLY CHAIN PROJECTS EXECUTED SUCCESSFULLY!
echo ===============================================================================
echo.
pause
