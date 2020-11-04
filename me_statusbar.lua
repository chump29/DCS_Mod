local base = _G

module('me_statusbar') -- bottom toolbar

local require = base.require
local string = base.string
local os = base.os
local math = base.math
local loader			= require('DialogLoader')
local U					= require('me_utilities')
local MapWindow			= require('me_map_window')
local Terrain			= require('terrain')
local UpdateManager		= require('UpdateManager')
local OptionsData		= require('Options.Data')
local mod_dictionary    = require('dictionary')
local NewMapView		= require('NewMapView')
local ListBoxItem       = require("ListBoxItem")
local LangController	= require('Mission.LangController')
local waitScreen        = require('me_wait_screen')
local module_mission    = require('me_mission')
local toolbar           = require('me_toolbar')
local me_menubar		= require('me_menubar')
local DB				= require('me_db_api')
local MeSettings		= require('MeSettings')
local panel_vehicle		= require('me_vehicle')
local panel_aircraft 	= require('me_aircraft')
local panel_ship		= require('me_ship')
local panel_static 		= require('me_static')
local panel_manager_resource	= require('me_manager_resource')

require('i18n').setup(_M)

local lastLangSelectItem = nil

cdata =
{
	new_mission_file = _('New Mission.miz'),
	long = _('LONG'),
	lat = _('LAT'),
	alt = _('ALT_STATUSBAR', 'ALT'),
	scale = _('SCALE'),
	pan = _('PAN/SELECT'),
	plane = _('ADD PLANE'),
	helicopter = _('ADD HELIC'),
	ship = _('ADD SHIP'),
	vehicle = _('ADD VEHICLE'),
	static = _('ADD STATIC'),
	wpt = _('ADD WPT'),
	trg = _('ADD TARGET'),
	zone = _('ADD ZONE'),
	template = _('ADD TEMPLATE'),
	tape = _('TAPE'),
	mgrs = _('MGRS'),
    MAP = _('sb_MAP','MAP'),
    SAT = _('sb_SAT','SAT'),
    ALT = _('sb_ALT','ALT'),
	showModels = _("Show models"),
	historical = _("Historical list of units"),
	metric = _('METRIC')
}

function create(x, y, w, h)
	window = loader.spawnDialogFromFile('MissionEditor/modules/dialogs/me_statusbar.dlg', cdata)
	window:setBounds(x, y, w, h)

	local container = window.container

	t_file = container.t_file
	t_long = container.t_long
	tt_long = container.tt_long
	t_lat = container.t_lat
	tt_lat = container.tt_lat
	t_mgrs = container.t_mgrs
	tt_mgrs = container.tt_mgrs
	tt_alt = container.tt_alt
	tbModels = container.tbModels

    rbMap  =   container.rbMap
    rbSat  =   container.rbSat
    rbAlt  =   container.rbAlt

    rbMap.onChange = onChange_rbMap
    rbSat.onChange = onChange_rbSat
    rbAlt.onChange = onChange_rbAlt

	tt_altUnitWidget = U.createUnitWidget(nil, tt_alt, U.altitudeUnits)

	t_state = container.t_state

	t_clock = window.t_clock

    comboListLangs = container.comboListLangs

    comboListLangs.onChange = comboListLangsonChange
	tbModels.onChange = tbModelsChange

	tbModels:setState(MeSettings.getShowModels())

	if base.test_topdown_view_models ~= true then
		tbModels:setVisible(false)
	end

	tbEras = container.tbEras

	tbEras.onChange = onChangeEras
	tbEras:setState(MeSettings.getShowEras())

	t_metric = container.t_metric
	tt_metric = container.tt_metric

end

function onChangeEras(self)
	MeSettings.setShowEras(self:getState())

	if panel_vehicle.isVisible() == true and panel_vehicle.changeEras() == false then
		panel_vehicle.show(false)
		toolbar.hideVehiclePanels()
		toolbar.untoggle_all_except()
		toolbar.untoggleButtons()
	end

	if panel_aircraft.isVisible() == true and panel_aircraft.changeEras() == false then
		panel_aircraft.show(false)
		toolbar.hideAirplanePanels()
		toolbar.untoggle_all_except()
		toolbar.untoggleButtons()
	end

	if panel_static.isVisible() == true and panel_static.changeEras() == false then
		panel_static.show(false)
		toolbar.untoggle_all_except()
		toolbar.untoggleButtons()
	end

	if panel_ship.isVisible() == true and panel_ship.changeEras() == false then
		panel_ship.show(false)
		toolbar.hideShipPanels()
		toolbar.untoggle_all_except()
		toolbar.untoggleButtons()
	end

	if panel_manager_resource.isVisible() == true then
		panel_manager_resource.updateGridLA()
	end
end

function tbModelsChange(self)
	MeSettings.setShowModels(self:getState())

	if self:getState() == true then
		for k,unit in base.pairs(base.module_mission.unit_by_id) do
			local unitDef = DB.unit_by_type[unit.type]
			local object = unit.boss.mapObjects.units[unit.index]
			base.module_mission.addPicModel(unit.boss, unit, object, unitDef)
		end
	else
		for k,unit in base.pairs(base.module_mission.unit_by_id) do
			local group = unit.boss
			if group.mapObjects.units[unit.index].picModel then
				group.mapObjects.units[unit.index].picModel = MapWindow.removeSceneObject(group.mapObjects.units[unit.index].picModel)
			end
		end
	end
end

function onChange_rbMap()
    NewMapView:setMapMode("map")
end

function onChange_rbSat()
    NewMapView:setMapMode("satellite")
end

function onChange_rbAlt()
    NewMapView:setMapMode("altitude")
end

function updateOptions()
	tt_altUnitWidget:setUnitSystem(OptionsData.getDifficulty('units'))

	local opt = OptionsData.getMiscellaneous('Coordinate_Display')

	local isMgrs   = opt == "MGRS"
	local isMetric = opt == "Metric"
	local isLL	=  not isMgrs and not isMetric
	t_mgrs	:setVisible(isMgrs)
	tt_mgrs	:setVisible(not isLL)
	tt_lat	:setVisible(isLL)
	tt_long	:setVisible(isLL)
	t_lat	:setVisible(isLL)
	t_long	:setVisible(isLL)
end

function updateLang()
    fillListboxLangs()
end

function show(visible)
	updateEnabledPanels()

	updateOptions()
	window:setVisible(visible)
    updateLang()

	if visible then
		UpdateManager.add(update)
	else
		UpdateManager.delete(update)
	end
end

function updateEnabledPanels()
	if MapWindow.isEmptyME() == true then
		window:setEnabled(false)
	else
		window:setEnabled(true)

		local MapMode = NewMapView:getMapMode()
		if MapMode == "satellite" then
			rbSat:setState(true)
		elseif MapMode == "altitude" then
			rbAlt:setState(true)
		else
			rbMap:setState(true)
		end
	end
end


function fillListboxLangs()
    if comboListLangs then
        comboListLangs:clear()
        local langs = mod_dictionary.getLangs()
        local selectItem
        local defaultItem
        for k,v in base.pairs(langs) do
            local name = v
            if v == 'DEFAULT' then
                name = 'DFLT'
            end
            local item = ListBoxItem.new(name)
            item.name = name
            item.id = v
            comboListLangs:insertItem(item)
            if LangController.getCurLang() == item.id then
                selectItem = item
            end
            if 'DEFAULT' == item.id then
                defaultItem = item
            end

        end

        if selectItem then
            comboListLangs:selectItem(selectItem)
            lastLangSelectItem = selectItem
        else
            comboListLangs:selectItem(defaultItem)
            lastLangSelectItem = defaultItem
        end
    end
end

function comboListLangsonChange(self, item)
    local yes		= _('YES')
    local no		= _('NO')
    local cancel	= _('CANCEL')

    if item and (LangController.getCurLang() ~= item.id) then
        waitScreen.setUpdateFunction(function()
            MapWindow.unselectAll()
            toolbar.untoggle_all_except(self)

            if module_mission.isSignedMission() ~= true and (module_mission.isMissionModified() or not module_mission.getMissionPathIsSaved()) then
                local button = me_menubar.showOnExitSavePrompt(yes, no, cancel)
                if button == yes then
					me_menubar.hideME()
                    toolbar.saveMission()

                    LangController.setSelectLang(item.id)
                    mod_dictionary.setCurDictionary(item.id)
                    module_mission.load(module_mission.mission.path)
					MapWindow.show(true)
                    updateLang()
                    fillListboxLangs()
                elseif button == no then
					me_menubar.hideME()
                    LangController.setSelectLang(item.id)
                    mod_dictionary.setCurDictionary(item.id)
                    module_mission.load(module_mission.mission.path)
					MapWindow.show(true)
                    updateLang()
                    fillListboxLangs()
                else
                    comboListLangs:selectItem(lastLangSelectItem)
                end
            else
				me_menubar.hideME()
                LangController.setSelectLang(item.id)
                mod_dictionary.setCurDictionary(item.id)
                module_mission.load(module_mission.mission.path)
				MapWindow.show(true)
                updateLang()
                fillListboxLangs()
            end
        end)
    end
end

function updateLatLong(x, y)
	if MapWindow.isEmptyME() ~= true then
		-- возвращает lat, long в градусах
		local lat, long = MapWindow.convertMetersToLatLon(x, y)
		-- FIXME: получать это значение 1 раз
		local coordDisplay = OptionsData.getMiscellaneous('Coordinate_Display')

		if coordDisplay == "Lat Long" then
			U.update_coords_LatLong('lat', U.toRadians(lat), tt_lat)
			U.update_coords_LatLong('long', U.toRadians(long), tt_long)
		elseif coordDisplay == "Lat Long Decimal" then
			U.update_coords_LatLongD('lat', U.toRadians(lat), tt_lat)
			U.update_coords_LatLongD('long', U.toRadians(long), tt_long)
		elseif coordDisplay == "Precise Lat Long" then
			U.update_coords_LatLongHornet('lat', U.toRadians(lat), tt_lat)
			U.update_coords_LatLongHornet('long', U.toRadians(long), tt_long)
		else
			tt_mgrs:setText(Terrain.GetMGRScoordinates(x,y))
		end

		local ix = math.floor(x + 0.5)
		local iz = math.floor(y + 0.5)
		local txt = string.format("X%+09d  Z%+09d", ix, iz)
		if coordDisplay == "Metric" then
			tt_mgrs:setText(txt)
		else
			tt_metric:setText(txt)
		end

		local alt = U.getAltitude(x, y)

		tt_altUnitWidget:setValue(alt)
	end
end


local mapStateNames_

function updateState()
	if MapWindow.isEmptyME() == true then
		return
	end

	if not mapStateNames_ then
		mapStateNames_ = {
			[MapWindow.getPanState()] = 				cdata.pan,
			[MapWindow.getCreatingPlaneState()] = 		cdata.plane,
			[MapWindow.getCreatingHelicopterState()] = 	cdata.helicopter,
			[MapWindow.getCreatingShipState()] = 		cdata.ship,
			[MapWindow.getCreatingVehicleState()]= 		cdata.vehicle,
			[MapWindow.getCreatingStaticState()] = 		cdata.static,
			[MapWindow.getAddingWaypointState()] = 		cdata.wpt,
			[MapWindow.getAddingTargetState()] = 		cdata.trg,
			[MapWindow.getCreatingTemplateState()] = 	cdata.template,
			[MapWindow.getTapeState()] = 				cdata.tape,
		}
	end

	local state = MapWindow.getState()
	local stateName = mapStateNames_[state] or cdata.pan

	t_state:setText(stateName)
end

function setFileName(a_fileName)
	t_file:setText(a_fileName);
end

local realTimePrev_

function update()
	local realTime = os.clock()

	if realTimePrev_ then
		if realTime - realTimePrev_ >= 1 then
			realTimePrev_ = realTime

			local date = os.date('*t')
			local dateStr = string.format("%2i.%02i.%i %i:%02i:%02i", date.day, date.month, date.year, date.hour, date.min, date.sec)

			t_clock:setText(dateStr)
		end
	else
		realTimePrev_ = realTime
	end
end