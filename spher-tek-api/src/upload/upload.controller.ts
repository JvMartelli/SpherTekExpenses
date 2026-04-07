import {
  Controller,
  Post,
  UseGuards,
  UseInterceptors,
  UploadedFile,
  Request,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { memoryStorage } from 'multer';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { UploadService } from './upload.service';

@UseGuards(JwtAuthGuard)
@Controller('upload')
export class UploadController {
  constructor(private uploadService: UploadService) {}

  @Post('foto')
  @UseInterceptors(FileInterceptor('foto', { storage: memoryStorage() }))
  async uploadFoto(@UploadedFile() file: Express.Multer.File, @Request() req) {
    const url = await this.uploadService.uploadFoto(
      file.buffer,
      file.originalname,
      file.mimetype,
    );
    return { url };
  }
}