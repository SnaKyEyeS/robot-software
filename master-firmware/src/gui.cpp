#include <thread>
#include "gui.h"
#include <string.h>
#include <stdio.h>
#include <gfx.h>
#include "gui/Menu.h"
#include "gui/PositionPage.h"
#include "gui/MovePage.h"
#include "gui/ActuatorPage.h"
#include "gui/MenuPage.h"
#include "main.h"

static void gui_thread()
{
    gfxInit();
    gwinSetDefaultStyle(&WhiteWidgetStyle, GFXOFF);
    gwinSetDefaultFont(gdispOpenFont("DejaVuSans32"));
    gdispClear(GFX_SILVER);
    gwinSetDefaultBgColor(GFX_SILVER);
    gdispSetOrientation(gOrientation90);

    WARNING("GUI init done");

    Menu m;

    auto base_position_page = PositionPage();
    auto base_move_page = MovePage();
    auto base_menu = MenuPage(m, "Base", &base_position_page, &base_move_page);

    auto front_left_page = ActuatorPage(&actuator_front_left, "Front left");
    auto front_center_page = ActuatorPage(&actuator_front_center, "Front center");
    auto front_right_page = ActuatorPage(&actuator_front_right, "Front right");
    auto back_left_page = ActuatorPage(&actuator_back_left, "Back left");
    auto back_center_page = ActuatorPage(&actuator_back_center, "Back center");
    auto back_right_page = ActuatorPage(&actuator_back_right, "Back right");

    auto actuator_menu = MenuPage(m, "Actuators",
                                  &front_left_page,
                                  &front_center_page,
                                  &front_right_page,
                                  &back_left_page,
                                  &back_center_page,
                                  &back_right_page);

    auto root_page = MenuPage(m, "Robot", &base_menu, &actuator_menu);

    m.enter_page(&root_page);
    m.event_loop();

    while (true) {
    }
}

void gui_start()
{
    std::thread thd(gui_thread);
    thd.detach();
}
