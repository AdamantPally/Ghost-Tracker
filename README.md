# Ghost-Tracker
Ghost Tracker is a specialized combat utility for Turtle WoW, specifically built to track procs that summon "The Lost". It serves as a tool for testing build efficiency and internal cooldowns (currently there's no ICD).


Key Features:

Summon Monitoring: Listens for the "Summon The Lost" combat log event to trigger tracking.

Dynamic Bars: Generates individual progress bars for every active ghost, showing the remaining 20-second duration for each.

Real-time Counter: Displays a global count of currently active ghosts next to the main icon.

Customizable UI: * Minimap Button: Provides a toggle for the settings menu with a "Ghost Tracker" tooltip.

Drag & Lock: Allows the HUD to be positioned freely while the settings menu is open.

Stable Scaling: Uses a manual "+" and "-" button system to safely resize the entire interface.

Persistence: Saves your custom scale and screen position to your character profile.


Simulation & Testing Macro To verify your UI layout, bar stacking, and scaling without entering combat, use the following macro:

Lua

/script arg1 = "You cast Summon The Lost."
/script GT_Anchor:GetScript("OnEvent")()
Usage: Click the macro multiple times to simulate multiple spawns and observe the stacking behavior and timers.


Client Limitations & Technical Notes

FIFO Logic (First-In, First-Out): The 1.12 client does not assign unique IDs to identical units. If a ghost is killed, the addon removes the oldest active timer, as it cannot distinguish between identical clones.

Combat Log Range: Detection is limited by the client's 50-yard combat log range. Summons outside this range may not be recorded.

Guardian Category: These summons are "Guardians," which do not have a standard pet bar. Combat log monitoring is the only method to track their presence.

API Stability: To prevent UI disappearing or flickering issues common in the 1.12 engine, manual scale buttons were used instead of sliders.


Commands

/gt: Opens the settings menu to unlock the UI for dragging or scaling.

/gt reset: Teleports the HUD to the center of the screen and resets the scale to 1.0.
