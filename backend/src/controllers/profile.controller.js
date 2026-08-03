const asyncHandler = require('../utils/asyncHandler');
const { sendSuccess } = require('../utils/apiResponse');
const profileService = require('../services/profile.service');
const { uploadProfileImage } = require('../services/storage.service');

const getProfile = asyncHandler(async (req, res) => {
  const profile = await profileService.getProfile(req.user.id);
  return sendSuccess(res, { data: profile });
});

const updateProfile = asyncHandler(async (req, res) => {
  const profile = await profileService.updateProfile(req.user.id, req.body);
  return sendSuccess(res, { message: 'Profile updated', data: profile });
});

const uploadAvatar = asyncHandler(async (req, res) => {
  const avatarUrl = await uploadProfileImage({
    userId: req.user.id,
    buffer: req.file.buffer,
    mimeType: req.file.mimetype,
    originalName: req.file.originalname,
  });
  const profile = await profileService.setAvatar(req.user.id, avatarUrl);
  return sendSuccess(res, { message: 'Profile image updated', data: profile });
});

module.exports = { getProfile, updateProfile, uploadAvatar };
