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
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('categorias')
export class CategoriasController {
  constructor(private categoriasService: CategoriasService) {}

  @Get()
  async listar(@Request() req) {
    return this.categoriasService.listar(req.user.empresa_id);
  }

  @Post()
  @Roles('administrador')
  async criar(@Body() body: any, @Request() req) {
    return this.categoriasService.criar(req.user.empresa_id, body);
  }

  @Patch(':id')
  @Roles('administrador')
  async atualizar(@Param('id') id: string, @Body() body: any, @Request() req) {
    return this.categoriasService.atualizar(id, req.user.empresa_id, body);
  }

  @Delete(':id')
  @Roles('administrador')
  async deletar(@Param('id') id: string, @Request() req) {
    return this.categoriasService.deletar(id, req.user.empresa_id);
  }
}