class Api::V1::SoundController < Api::V1Controller
	def play_custom
		if ConfigValue.enable_sound
			CustomSoundfileWorker.perform_async(params[:id])
		end

		render status: 200, text: ""
	end
end
