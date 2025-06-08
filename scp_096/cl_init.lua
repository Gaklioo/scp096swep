include("sh_shared.lua")

local markedTable = nil

net.Receive("SCP_096_SendList", function()
    local str = net.ReadString()
    
    if str == "" then
        print("String is nill")
    end
    
    markedTable = nil
    markedTable = util.JSONToTable(str)
end)

function SWEP:PrimaryAttack() end
function SWEP:SecondaryAttack() end

hook.Add("PostDrawTranslucentRenderables", "SCP_096_DrawPlayers", function()
    if not markedTable or table.Count(markedTable) == 0 then return end

    for _, ply in ipairs(player.GetAll()) do
        if not IsValid(ply) or not ply:Alive() then continue end

        local steamID = ply:SteamID()
        if not markedTable[steamID] then continue end

        local bone = ply:LookupBone("ValveBiped.Bip01_Head1")
        if not bone then continue end

        local pos = ply:GetBonePosition(bone)
        if not pos then continue end

        cam.Start3D()
            cam.IgnoreZ(true)
            render.SetColorMaterial()
            render.DrawSphere(pos, 20, 30, 30, Color(180, 180, 180, 200))
            cam.IgnoreZ(false)
        cam.End3D()
    end
end)