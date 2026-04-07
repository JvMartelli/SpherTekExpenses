import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  UseGuards,
  Request,
} from '@nestjs/common';
import { CategoriasService } from './categorias.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('categorias')
export class CategoriasController {
  constructor(private categoriasService: CategoriasService) {}

  @Get()
  async listar(@Request() req) {
    return this.categoriasService.listar(req.user.empresa_id);
  }

  @Post()
  async criar(@Body() body: any, @Request() req) {
    return this.categoriasService.criar(req.user.empresa_id, body);
  }

  @Patch(':id')
  async atualizar(@Param('id') id: string, @Body() body: any, @Request() req) {
    return this.categoriasService.atualizar(id, req.user.empresa_id, body);
  }

  @Delete(':id')
  async deletar(@Param('id') id: string, @Request() req) {
    return this.categoriasService.deletar(id, req.user.empresa_id);
  }
}